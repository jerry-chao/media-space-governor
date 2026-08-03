/// Governance-oriented measure of how likely a media resource is to still
/// matter, derived from recency and evidence of use.
///
/// Ordering: `active` > `lukewarm` > `cold`.
public enum UsageHeat: Int, Codable, Sendable, Equatable, Comparable {
    case cold = 0
    case lukewarm = 1
    case active = 2

    public static func < (lhs: UsageHeat, rhs: UsageHeat) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
