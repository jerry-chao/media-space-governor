import Foundation

/// Service-derived truth about one Remote Archive copy.
///
/// The client caches a snapshot of this; the archive service owns the lifecycle.
public struct ArchiveRecord: Codable, Sendable, Equatable {
    public let id: String
    public let resourceID: String
    public let archiveState: ArchiveState
    /// Opaque object identity in the object storage archive.
    public let remoteObjectID: String?
    /// Whether the archived object passed integrity verification, where known.
    public let integrityVerified: Bool?
    /// Whether the archived original is currently available to restore.
    public let restoreAvailable: Bool?
    /// When this snapshot was last reconciled from the archive service.
    public let lastSyncedAt: Date?

    public init(
        id: String,
        resourceID: String,
        archiveState: ArchiveState,
        remoteObjectID: String? = nil,
        integrityVerified: Bool? = nil,
        restoreAvailable: Bool? = nil,
        lastSyncedAt: Date? = nil
    ) {
        self.id = id
        self.resourceID = resourceID
        self.archiveState = archiveState
        self.remoteObjectID = remoteObjectID
        self.integrityVerified = integrityVerified
        self.restoreAvailable = restoreAvailable
        self.lastSyncedAt = lastSyncedAt
    }
}
