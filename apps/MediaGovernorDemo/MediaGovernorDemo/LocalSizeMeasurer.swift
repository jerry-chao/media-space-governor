import Foundation
import Photos

/// Result of measuring the locally available original components of one asset.
enum LocalSizeOutcome: Equatable {
    /// Locally available original bytes were streamed and counted.
    case measured(UInt64)
    /// No original component is available on-device; network download was not
    /// requested, so nothing was measured.
    case unavailable
}

/// Streams the original components of a PHAsset with network access disabled,
/// counts the bytes, and discards them. Never downloads iCloud originals and
/// never retains media content.
final class LocalSizeMeasurer {

    /// The component types required to preserve an Original Archive Copy:
    /// the main original, any full-size adjusted variant, the paired video of
    /// a Live Photo, and edit adjustments.
    private static let originalComponentTypes: Set<PHAssetResourceType> = [
        .photo, .fullSizePhoto,
        .video, .fullSizeVideo,
        .pairedVideo,
        .adjustmentData,
    ]

    func measure(_ asset: PHAsset) async -> LocalSizeOutcome {
        let components = PHAssetResource.assetResources(for: asset)
            .filter { Self.originalComponentTypes.contains($0.type) }
        guard !components.isEmpty else { return .unavailable }

        var total: UInt64 = 0
        var anyBytesSeen = false
        var failed = false

        for component in components {
            if Task.isCancelled { return .unavailable }
            let options = PHAssetResourceRequestOptions()
            options.isNetworkAccessAllowed = false

            await withCheckedContinuation { continuation in
                PHAssetResourceManager.default().requestData(
                    for: component,
                    options: options
                ) { data in
                    total += UInt64(data.count)
                    anyBytesSeen = true
                } completionHandler: { error in
                    if error != nil { failed = true }
                    continuation.resume()
                }
            }
        }

        // A failed request must never be presented as an accurate partial
        // measurement; only a fully delivered set of local components counts.
        if failed { return .unavailable }
        return anyBytesSeen ? .measured(total) : .unavailable
    }
}
