/// A user-reviewable set of governance recommendations grouped by governance
/// value so they can be confirmed and executed together.
///
/// Batches are fully actionable by construction: every member is cleanup-
/// eligible, so there are no blocking reasons to record in phase 1.
public struct GovernanceBatch: Codable, Sendable, Equatable {
    public let id: String
    public let batchType: GovernanceBatchType
    /// The action every member requires; always `.cleanup` in phase 1.
    public let action: GovernanceAction
    public let resourceIDs: [String]
    public let totalSpaceSavingBytes: UInt64

    public init(
        id: String,
        batchType: GovernanceBatchType,
        action: GovernanceAction,
        resourceIDs: [String],
        totalSpaceSavingBytes: UInt64
    ) {
        self.id = id
        self.batchType = batchType
        self.action = action
        self.resourceIDs = resourceIDs
        self.totalSpaceSavingBytes = totalSpaceSavingBytes
    }
}

/// Governance-Driven Grouping families for phase 1.
public enum GovernanceBatchType: String, Codable, Sendable, Equatable, CaseIterable {
    case largeColdVideos
    case coldScreenshots
    case coldCameraPhotos
}
