import Foundation

/// The user-facing state transitions of the workflow: confirmed local cleanup
/// and restore. These are the only places a `LocalPrimary` leaves or returns
/// to the device.
public struct MediaWorkflow {
    public let engine: GovernanceEngine

    public init(engine: GovernanceEngine = GovernanceEngine()) {
        self.engine = engine
    }

    /// Cleans the Local Primary after the user explicitly confirms, but only if
    /// the resource is cleanup-eligible. Throws `GovernanceError.cleanupBlocked`
    /// otherwise; it never silently deletes.
    public func confirmCleanup(
        of resource: MediaResource,
        archiveRecord: ArchiveRecord?,
        now: Date
    ) throws -> MediaResource {
        let eligibility = engine.cleanupEligibility(
            resource: resource,
            archiveRecord: archiveRecord,
            now: now
        )
        guard eligibility == .eligibleForCleanup else {
            throw GovernanceError.cleanupBlocked(eligibility)
        }
        var updated = resource
        updated.localPresence = .archivedLocalCleaned
        return updated
    }

    /// Brings an archived resource back onto the device as a usable local copy.
    ///
    /// Restore always requires Archive Completion, so it can never fabricate a
    /// local copy that has no remote original behind it. Throws
    /// `GovernanceError.restoreBlocked` otherwise.
    public func restore(_ resource: MediaResource, archiveRecord: ArchiveRecord?) throws -> MediaResource {
        guard let record = archiveRecord, record.archiveState == .archiveComplete else {
            throw GovernanceError.restoreBlocked
        }
        var updated = resource
        updated.localPresence = .localAndArchived
        return updated
    }
}
