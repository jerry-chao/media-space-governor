/// The full governance state derived for one resource by the engine.
public struct ResourceGovernanceState: Codable, Sendable, Equatable {
    public let resourceID: String
    public let usageHeat: UsageHeat
    public let isColdCandidate: Bool
    public let isProtected: Bool
    public let isArchiveComplete: Bool
    public let cleanupEligibility: CleanupEligibility

    public init(
        resourceID: String,
        usageHeat: UsageHeat,
        isColdCandidate: Bool,
        isProtected: Bool,
        isArchiveComplete: Bool,
        cleanupEligibility: CleanupEligibility
    ) {
        self.resourceID = resourceID
        self.usageHeat = usageHeat
        self.isColdCandidate = isColdCandidate
        self.isProtected = isProtected
        self.isArchiveComplete = isArchiveComplete
        self.cleanupEligibility = cleanupEligibility
    }
}
