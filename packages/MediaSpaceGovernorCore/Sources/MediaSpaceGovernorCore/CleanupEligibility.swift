/// Why a resource is not, or is now, available for local cleanup.
public enum CleanupEligibility: String, Codable, Sendable, Equatable, CaseIterable {
    /// No archive record, or the archive is not complete.
    case blockedByMissingArchiveCompletion
    /// Archive complete but the resource is Protected.
    case blockedAsProtectedResource
    /// Archive complete, not protected, but not a Cold Resource under policy.
    case blockedByPolicy
    /// Archive complete, not protected, cold, and present locally.
    case eligibleForCleanup
    /// Local copy not usable on the device: cleaned, or restore never completed.
    case cleanedLocally
}
