/// The Default Cooling Policy: system-provided thresholds with limited
/// user adjustment. Not a general-purpose rule engine.
public struct PolicySettings: Codable, Sendable, Equatable {
    /// Default age without usage evidence before an ordinary resource cools.
    public var coolingThresholdDays: Int
    /// Lower threshold applied to screenshots when aggressive governance is on.
    public var screenshotCoolingThresholdDays: Int
    public var aggressiveScreenshotGovernance: Bool
    /// A video at or above this size is a "large video" governance target.
    public var largeVideoSizeBytes: UInt64
    public var preferLargeVideoGovernance: Bool

    public init(
        coolingThresholdDays: Int = 180,
        screenshotCoolingThresholdDays: Int = 90,
        aggressiveScreenshotGovernance: Bool = true,
        largeVideoSizeBytes: UInt64 = 100 * 1024 * 1024,
        preferLargeVideoGovernance: Bool = true
    ) {
        self.coolingThresholdDays = coolingThresholdDays
        self.screenshotCoolingThresholdDays = screenshotCoolingThresholdDays
        self.aggressiveScreenshotGovernance = aggressiveScreenshotGovernance
        self.largeVideoSizeBytes = largeVideoSizeBytes
        self.preferLargeVideoGovernance = preferLargeVideoGovernance
    }

    public static let `default` = PolicySettings()
}
