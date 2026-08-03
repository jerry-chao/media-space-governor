/// The service-controlled lifecycle of a Remote Archive copy.
///
/// Upload success alone is never `archiveComplete`; the archive service must
/// verify object existence and integrity and record a restore mapping first.
public enum ArchiveState: String, Codable, Sendable, Equatable, CaseIterable {
    case notRequested
    case pending
    case uploading
    case verifying
    case archiveComplete
    case archiveFailed
}
