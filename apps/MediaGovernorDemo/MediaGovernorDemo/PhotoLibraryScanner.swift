import Foundation
import Photos
import MediaSpaceGovernorCore

/// The result of one inventory scan: normalized, platform-free item facts
/// plus whether the authorization covers the full library or a limited
/// selection (Library Access Coverage).
struct LibraryScanResult {
    let items: [LibraryInventoryItem]
    let isLimitedAccess: Bool
}

enum PhotoLibraryScanner {
    static func requestAccess() async -> PHAuthorizationStatus {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                continuation.resume(returning: status)
            }
        }
    }

    /// Enumerates visible photos and videos on a background queue and
    /// projects each into platform-free LibraryInventoryItem facts. Assets
    /// without a creation date are skipped rather than fabricated.
    static func scan(isLimitedAccess: Bool) async -> LibraryScanResult {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(returning: scanSynchronously(isLimitedAccess: isLimitedAccess))
            }
        }
    }

    private static func scanSynchronously(isLimitedAccess: Bool) -> LibraryScanResult {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: options)
        var items: [LibraryInventoryItem] = []
        items.reserveCapacity(assets.count)

        assets.enumerateObjects { asset, _, _ in
            guard let createdAt = asset.creationDate else { return }

            let mediaType: MediaType
            switch asset.mediaType {
            case .image:
                mediaType = .image
            case .video:
                mediaType = .video
            default:
                return // unsupported kinds never enter the inventory
            }

            items.append(
                LibraryInventoryItem(
                    id: asset.localIdentifier,
                    mediaType: mediaType,
                    isScreenshot: asset.mediaSubtypes.contains(.photoScreenshot),
                    isFavorite: asset.isFavorite,
                    isHidden: asset.isHidden,
                    createdAt: createdAt
                )
            )
        }
        return LibraryScanResult(items: items, isLimitedAccess: isLimitedAccess)
    }
}
