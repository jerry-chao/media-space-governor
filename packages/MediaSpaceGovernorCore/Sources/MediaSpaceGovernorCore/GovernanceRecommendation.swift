/// A system-generated recommendation proposing an archive or cleanup action.
///
/// A recommendation never executes anything; it proposes.
public struct GovernanceRecommendation: Codable, Sendable, Equatable {
    public let resourceID: String
    public let action: GovernanceAction
    public let rationale: [String]

    public init(resourceID: String, action: GovernanceAction, rationale: [String]) {
        self.resourceID = resourceID
        self.action = action
        self.rationale = rationale
    }
}

public enum GovernanceAction: String, Codable, Sendable, Equatable {
    case archive
    case cleanup
}
