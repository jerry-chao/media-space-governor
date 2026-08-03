import Foundation

/// The single seam of the Media Space Governance workflow.
///
/// It classifies media on-device, derives recommendations and governance
/// batches, and answers cleanup-eligibility questions. It never deletes or
/// uploads anything itself.
public struct GovernanceEngine {
    public let policy: PolicySettings

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
        let ageDays = now.timeIntervalSince(resource.createdAt) / 86_400
        guard ageDays >= 0 else { return .active }

        // Evidence of use inside the cooling window, or simply young enough.
        if let evidence = recentEvidenceDays(resource, now: now), evidence < threshold {
            return .active
        }
        if ageDays < threshold {
            return .active
        }
        // Old enough, but there is some (now stale) usage evidence.
        if hasUsageEvidence(resource) {
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
        let evidenceDates = [resource.lastViewedAt, resource.lastSharedAt, resource.lastEditedAt]
            .compactMap { $0 }
            .map { now.timeIntervalSince($0) / 86_400 }
        return evidenceDates.min()
    }

    private func hasUsageEvidence(_ resource: MediaResource) -> Bool {
        resource.lastViewedAt != nil || resource.lastSharedAt != nil || resource.lastEditedAt != nil
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
        if resource.localPresence == .archivedLocalCleaned {
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

    // MARK: - Recommendations

    /// Governance Recommendations for an inventory: archive cold unarchived
    /// resources, clean cold archived resources. Protected Resources never
    /// receive a recommendation.
    public func recommendations(
        resources: [MediaResource],
        archiveRecords: [ArchiveRecord],
        now: Date
    ) -> [GovernanceRecommendation] {
        let archiveByResource = Dictionary(
            uniqueKeysWithValues: archiveRecords.map { ($0.resourceID, $0) }
        )
        return resources
            .filter { !$0.isProtected }
            .filter { isColdCandidate($0, now: now) }
            .sorted { $0.id < $1.id }
            .map { resource in
                let isArchiveComplete = archiveByResource[resource.id]?.archiveState == .archiveComplete
                if isArchiveComplete {
                    return GovernanceRecommendation(
                        resourceID: resource.id,
                        action: .cleanup,
                        rationale: ["Cold resource with Archive Completion"]
                    )
                }
                return GovernanceRecommendation(
                    resourceID: resource.id,
                    action: .archive,
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
        let archiveByResource = Dictionary(
            uniqueKeysWithValues: archiveRecords.map { ($0.resourceID, $0) }
        )

        func isActionable(_ resource: MediaResource) -> Bool {
            guard !resource.isProtected else { return false }
            guard resource.localPresence != .archivedLocalCleaned else { return false }
            guard archiveByResource[resource.id]?.archiveState == .archiveComplete else { return false }
            return isColdCandidate(resource, now: now)
        }

        let actionable = resources.filter(isActionable).sorted { $0.id < $1.id }

        let largeColdVideos = actionable.filter { resource in
            policy.preferLargeVideoGovernance
                && resource.mediaType == .video
                && resource.sizeBytes >= policy.largeVideoSizeBytes
        }
        let coldScreenshots = actionable.filter { $0.contentHint == .screenshot }
        let oldArchivedImages = actionable.filter { $0.contentHint == .cameraPhoto }

        var batches: [GovernanceBatch] = []
        if !largeColdVideos.isEmpty {
            batches.append(makeBatch(type: .largeColdVideos, resources: largeColdVideos))
        }
        if !coldScreenshots.isEmpty {
            batches.append(makeBatch(type: .coldScreenshots, resources: coldScreenshots))
        }
        if !oldArchivedImages.isEmpty {
            batches.append(makeBatch(type: .oldArchivedImages, resources: oldArchivedImages))
        }
        return batches
    }

    private func makeBatch(type: GovernanceBatchType, resources: [MediaResource]) -> GovernanceBatch {
        GovernanceBatch(
            id: type.rawValue,
            batchType: type,
            resourceIDs: resources.map(\.id),
            totalSpaceSavingBytes: resources.reduce(0) { $0 + $1.sizeBytes }
        )
    }
}
