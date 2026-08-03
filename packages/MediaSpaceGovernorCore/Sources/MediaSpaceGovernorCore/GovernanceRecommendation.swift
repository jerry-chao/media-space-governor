/// A system-generated recommendation proposing an archive or cleanup action.
///
/// A recommendation never executes anything; it proposes. Its `id` is derived
/// from the action and resource so it stays stable across inventory rescans.
public struct GovernanceRecommendation: Codable, Sendable, Equatable {
    public let id: String
    public let resourceID: String
    public let action: GovernanceAction
    /// Local bytes the action would free on the device; zero for archive actions.
    public let spaceSavingBytes: UInt64
    /// Cleanup eligibility backing a cleanup action; nil for archive actions.
    public let cleanupEligibility: CleanupEligibility?
    public let rationale: [String]

    public init(
        resourceID: String,
        action: GovernanceAction,
        spaceSavingBytes: UInt64,
        cleanupEligibility: CleanupEligibility?,
        rationale: [String]
    ) {
        self.id = "\(action.rawValue)-\(resourceID)"
        self.resourceID = resourceID
        self.action = action
        self.spaceSavingBytes = spaceSavingBytes
        self.cleanupEligibility = cleanupEligibility
        self.rationale = rationale
    }
}

public enum GovernanceAction: String, Codable, Sendable, Equatable {
    case archive
    case cleanup
}
