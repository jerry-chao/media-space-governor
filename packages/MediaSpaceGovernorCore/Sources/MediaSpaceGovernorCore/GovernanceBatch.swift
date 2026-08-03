/// A user-reviewable set of governance recommendations grouped by governance
/// value so they can be confirmed and executed together.
public struct GovernanceBatch: Codable, Sendable, Equatable {
    public let id: String
    public let batchType: GovernanceBatchType
    public let resourceIDs: [String]
    public let totalSpaceSavingBytes: UInt64

    public init(
        id: String,
        batchType: GovernanceBatchType,
        resourceIDs: [String],
        totalSpaceSavingBytes: UInt64
    ) {
        self.id = id
        self.batchType = batchType
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
