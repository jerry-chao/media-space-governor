import Foundation

/// Device-derived facts about one photo or video on the managed device.
///
/// This record intentionally carries no archive truth: archive state lives in
/// `ArchiveRecord`, which is reconciled from the archive service.
public struct MediaResource: Codable, Sendable, Equatable {
    public let id: String
    public let mediaType: MediaType
    public let contentHint: ContentHint
    public let sizeBytes: UInt64
    public let createdAt: Date
    /// Most recent on-device view time, where the platform makes it available.
    public let lastViewedAt: Date?
    /// Most recent share time, where the platform makes it available.
    public let lastSharedAt: Date?
    /// Most recent edit time, where the platform makes it available.
    public let lastEditedAt: Date?
    public var isProtected: Bool
    public var localPresence: LocalPresence

    public init(
        id: String,
        mediaType: MediaType,
        contentHint: ContentHint,
        sizeBytes: UInt64,
        createdAt: Date,
        lastViewedAt: Date? = nil,
        lastSharedAt: Date? = nil,
        lastEditedAt: Date? = nil,
        isProtected: Bool = false,
        localPresence: LocalPresence = .localOnly
    ) {
        self.id = id
        self.mediaType = mediaType
        self.contentHint = contentHint
        self.sizeBytes = sizeBytes
        self.createdAt = createdAt
        self.lastViewedAt = lastViewedAt
        self.lastSharedAt = lastSharedAt
        self.lastEditedAt = lastEditedAt
        self.isProtected = isProtected
        self.localPresence = localPresence
    }

    /// Whether a usable working copy is present on the device.
    public var isLocallyPresent: Bool {
        localPresence == .localOnly || localPresence == .localAndArchived
    }

    /// The dates of the most recent view/share/edit evidence, if any.
    public var usageEvidenceDates: [Date] {
        [lastViewedAt, lastSharedAt, lastEditedAt].compactMap { $0 }
    }

    /// Whether there is any recorded usage evidence at all.
    public var hasUsageEvidence: Bool {
        !usageEvidenceDates.isEmpty
    }
}
