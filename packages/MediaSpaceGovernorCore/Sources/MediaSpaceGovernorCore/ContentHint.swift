/// A shallow, governance-oriented content class derived on-device.
///
/// Phase 1 only distinguishes high-governance-value categories. Deeper semantic
/// classification (people, scenes, events) is intentionally out of scope.
public enum ContentHint: String, Codable, Sendable, Equatable, CaseIterable {
    case screenshot
    case cameraPhoto
    case ordinaryVideo
}
