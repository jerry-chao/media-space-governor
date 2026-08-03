/// Service-derived truth about one Remote Archive copy.
///
/// The client caches a snapshot of this; the archive service owns the lifecycle.
public struct ArchiveRecord: Codable, Sendable, Equatable {
    public let id: String
    public let resourceID: String
    public let archiveState: ArchiveState
    /// Opaque object identity in the object storage archive.
    public let remoteObjectID: String?

    public init(
        id: String,
        resourceID: String,
        archiveState: ArchiveState,
        remoteObjectID: String? = nil
    ) {
        self.id = id
        self.resourceID = resourceID
        self.archiveState = archiveState
        self.remoteObjectID = remoteObjectID
    }
}
