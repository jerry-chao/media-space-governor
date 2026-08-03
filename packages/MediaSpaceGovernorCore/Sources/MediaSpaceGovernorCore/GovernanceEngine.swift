import Foundation

/// The single seam of the Media Space Governance workflow.
///
/// It classifies media on-device, derives recommendations and governance
/// batches, and answers cleanup-eligibility questions. It never deletes or
/// uploads anything itself.
public struct GovernanceEngine {
    public let policy: PolicySettings

    private static let secondsPerDay: TimeInterval = 86_400

    public init(policy: PolicySettings = .default) {
        self.policy = policy
    }

    // MARK: - Cooling policy

    /// The age threshold that applies to a resource under the current policy.
    public func applicableCoolingThreshold(_ resource: MediaResource) -> Int {
        if policy.aggressiveScreenshotGovernance && resource.contentHint == .screenshot {
            return policy.screenshotCoolingThresholdDays
        }
        return policy.coolingThresholdDays
    }

    // MARK: - Usage heat

    public func usageHeat(_ resource: MediaResource, now: Date) -> UsageHeat {
        let threshold = Double(applicableCoolingThreshold(resource))
        let ageDays = now.timeIntervalSince(resource.createdAt) / Self.secondsPerDay
        guard ageDays >= 0 else { return .active }

        // Evidence of use inside the cooling window, or simply young enough.
        if let evidence = recentEvidenceDays(resource, now: now), evidence < threshold {
            return .active
        }
        if ageDays < threshold {
            return .active
        }
        // Old enough, but there is some (now stale) usage evidence.
        if resource.hasUsageEvidence {
            return .lukewarm
        }
        // Old enough and no usage evidence at all.
        return .cold
    }

    public func isColdCandidate(_ resource: MediaResource, now: Date) -> Bool {
        usageHeat(resource, now: now) == .cold
    }

    /// Days since the most recent of view/share/edit evidence, if any exists.
    private func recentEvidenceDays(_ resource: MediaResource, now: Date) -> Double? {
        resource.usageEvidenceDates
            .map { now.timeIntervalSince($0) / Self.secondsPerDay }
            .min()
    }

    // MARK: - Classification

    /// Derives the full governance state for one resource.
    public func classify(
        _ resource: MediaResource,
        archiveRecord: ArchiveRecord?,
        now: Date
    ) -> ResourceGovernanceState {
        let heat = usageHeat(resource, now: now)
        return ResourceGovernanceState(
            resourceID: resource.id,
            usageHeat: heat,
            isColdCandidate: heat == .cold,
            isProtected: resource.isProtected,
            isArchiveComplete: archiveRecord?.archiveState == .archiveComplete,
            cleanupEligibility: cleanupEligibility(resource: resource, archiveRecord: archiveRecord, now: now)
        )
    }

    // MARK: - Cleanup eligibility

    /// Whether a local cleanup action would currently be permitted.
    ///
    /// Cleanup always requires Archive Completion, is never offered for
    /// Protected Resources, and only applies to Cold Resources that are still
    /// present locally.
    public func cleanupEligibility(
        resource: MediaResource,
        archiveRecord: ArchiveRecord?,
        now: Date
    ) -> CleanupEligibility {
        guard resource.isLocallyPresent else {
            return .cleanedLocally
        }
        guard let record = archiveRecord, record.archiveState == .archiveComplete else {
            return .blockedByMissingArchiveCompletion
        }
        guard !resource.isProtected else {
            return .blockedAsProtectedResource
        }
        guard isColdCandidate(resource, now: now) else {
            return .blockedByPolicy
        }
        return .eligibleForCleanup
    }

    /// The single cleanup predicate shared by eligibility, recommendations,
    /// and batch grouping, so all three can never drift apart.
    private func isCleanupEligible(
        resource: MediaResource,
        archiveRecord: ArchiveRecord?,
        now: Date
    ) -> Bool {
        cleanupEligibility(resource: resource, archiveRecord: archiveRecord, now: now) == .eligibleForCleanup
    }

    // MARK: - Recommendations

    /// Governance Recommendations for an inventory: archive cold unarchived
    /// resources, clean cold archived resources that are still locally present.
    /// Protected Resources and resources not fully present locally never receive
    /// a recommendation.
    public func recommendations(
        resources: [MediaResource],
        archiveRecords: [ArchiveRecord],
        now: Date
    ) -> [GovernanceRecommendation] {
        let archiveByResource = archiveIndex(archiveRecords)
        return sortedByID(
            resources
                .filter { !$0.isProtected }
                .filter { isColdCandidate($0, now: now) }
        ).compactMap { resource in
            guard resource.isLocallyPresent else { return nil }
            let record = archiveByResource[resource.id]
            if record?.archiveState == .archiveComplete {
                guard isCleanupEligible(resource: resource, archiveRecord: record, now: now) else {
                    return nil
                }
                return GovernanceRecommendation(
                    resourceID: resource.id,
                    action: .cleanup,
                    spaceSavingBytes: resource.sizeBytes,
                    cleanupEligibility: .eligibleForCleanup,
                    rationale: ["Cold resource with Archive Completion"]
                )
            }
            return GovernanceRecommendation(
                resourceID: resource.id,
                action: .archive,
                spaceSavingBytes: 0,
                cleanupEligibility: nil,
                rationale: ["Cold resource not yet archived"]
            )
        }
    }

    // MARK: - Governance batches

    /// Groups actionable resources into Governance-Driven batches.
    ///
    /// A resource is actionable when it is a Cold Resource, archive-complete,
    /// not Protected, and still present locally.
    public func batches(
        resources: [MediaResource],
        archiveRecords: [ArchiveRecord],
        now: Date
    ) -> [GovernanceBatch] {
        let archiveByResource = archiveIndex(archiveRecords)

        func isActionable(_ resource: MediaResource) -> Bool {
            isCleanupEligible(
                resource: resource,
                archiveRecord: archiveByResource[resource.id],
                now: now
            )
        }

        let actionable = sortedByID(resources.filter(isActionable))

        let largeColdVideos = actionable.filter { resource in
            policy.preferLargeVideoGovernance
                && resource.mediaType == .video
                && resource.sizeBytes >= policy.largeVideoSizeBytes
        }
        let coldScreenshots = actionable.filter { $0.contentHint == .screenshot }
        let coldCameraPhotos = actionable.filter { $0.contentHint == .cameraPhoto }

        var batches: [GovernanceBatch] = []
        if !largeColdVideos.isEmpty {
            batches.append(makeBatch(type: .largeColdVideos, resources: largeColdVideos))
        }
        if !coldScreenshots.isEmpty {
            batches.append(makeBatch(type: .coldScreenshots, resources: coldScreenshots))
        }
        if !coldCameraPhotos.isEmpty {
            batches.append(makeBatch(type: .coldCameraPhotos, resources: coldCameraPhotos))
        }
        return batches
    }

    private func makeBatch(type: GovernanceBatchType, resources: [MediaResource]) -> GovernanceBatch {
        GovernanceBatch(
            id: type.rawValue,
            batchType: type,
            action: .cleanup,
            resourceIDs: resources.map(\.id),
            totalSpaceSavingBytes: resources.reduce(0) { $0 + $1.sizeBytes }
        )
    }

    /// Builds a `resourceID -> record` index once, so callers never hand-roll it.
    ///
    /// Keeps the first record on a duplicate `resourceID` so a stale
    /// reconciliation snapshot can never crash the engine.
    private func archiveIndex(_ records: [ArchiveRecord]) -> [String: ArchiveRecord] {
        Dictionary(records.map { ($0.resourceID, $0) }, uniquingKeysWith: { first, _ in first })
    }

    private func sortedByID(_ resources: [MediaResource]) -> [MediaResource] {
        resources.sorted { $0.id < $1.id }
    }
}
