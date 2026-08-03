/// Errors raised by the workflow when a transition is not permitted.
public enum GovernanceError: Error, Sendable, Equatable {
    /// Cleanup was refused because the resource is not cleanup-eligible.
    case cleanupBlocked(CleanupEligibility)
}
