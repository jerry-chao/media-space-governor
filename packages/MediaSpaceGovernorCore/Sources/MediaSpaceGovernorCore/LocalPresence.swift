/// Whether the media's working copy is present on the managed device.
public enum LocalPresence: String, Codable, Sendable, Equatable, CaseIterable {
    /// Only exists locally; no remote archive.
    case localOnly
    /// Present locally and archived remotely.
    case localAndArchived
    /// Archived remotely and cleaned from the device.
    case archivedLocalCleaned
}
