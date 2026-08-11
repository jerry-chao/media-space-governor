import Foundation

/// Normalized, platform-free facts about one visible library asset, produced
/// by the platform media-access adapter. No Photos framework types appear here.
public struct LibraryInventoryItem: Codable, Sendable, Equatable {
    public let id: String
    public let mediaType: MediaType
    public let isScreenshot: Bool
    public let isFavorite: Bool
    public let isHidden: Bool
    public let createdAt: Date

    public init(
        id: String,
        mediaType: MediaType,
        isScreenshot: Bool,
        isFavorite: Bool,
        isHidden: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.mediaType = mediaType
        self.isScreenshot = isScreenshot
        self.isFavorite = isFavorite
        self.isHidden = isHidden
        self.createdAt = createdAt
    }
}

/// Maps normalized library facts to domain resources. The single place the
/// shallow Content Hint rules and Protected Resource mapping live, so they
/// are testable without a device and identical across platforms.
public enum LibraryInventory {

    /// Maps one item to its MediaResource, or nil when it must be excluded
    /// (hidden items are never inventoried in phase 1). A mapped resource is
    /// always unmeasured until the local original has been measured.
    public static func resource(for item: LibraryInventoryItem) -> MediaResource? {
        guard !item.isHidden else { return nil }

        let contentHint: ContentHint
        switch item.mediaType {
        case .video:
            contentHint = .ordinaryVideo
        case .image:
            contentHint = item.isScreenshot ? .screenshot : .cameraPhoto
        }

        return MediaResource(
            id: item.id,
            mediaType: item.mediaType,
            contentHint: contentHint,
            sizeBytes: nil,
            createdAt: item.createdAt,
            isProtected: item.isFavorite,
            localPresence: .localOnly
        )
    }
}
