import Foundation
import XCTest
@testable import MediaSpaceGovernorCore

/// Shared fixture helpers. `now` is a fixed instant so all assertions are
/// deterministic and independent of wall-clock time.
enum Fixtures {
    static let now = Date(timeIntervalSince1970: 0)
    static let day: TimeInterval = 86_400

    static func daysAgo(_ days: TimeInterval, from reference: Date = now) -> Date {
        reference.addingTimeInterval(-days * day)
    }

    static func archive(
        for resourceID: String,
        state: ArchiveState = .archiveComplete
    ) -> ArchiveRecord {
        ArchiveRecord(id: "archive-\(resourceID)", resourceID: resourceID, archiveState: state)
    }

    /// A Cold Resource: old enough that no usage evidence can keep it active.
    static func coldVideo(
        id: String,
        sizeBytes: UInt64? = 50 * 1024 * 1024,
        protected: Bool = false,
        presence: LocalPresence = .localAndArchived
    ) -> MediaResource {
        MediaResource(
            id: id,
            mediaType: .video,
            contentHint: .ordinaryVideo,
            sizeBytes: sizeBytes,
            createdAt: daysAgo(400),
            isProtected: protected,
            localPresence: presence
        )
    }

    /// A Cold camera photo, the `coldCameraPhotos` batch family.
    static func coldCameraPhoto(
        id: String,
        sizeBytes: UInt64? = 4 * 1024 * 1024,
        protected: Bool = false,
        presence: LocalPresence = .localAndArchived
    ) -> MediaResource {
        MediaResource(
            id: id,
            mediaType: .image,
            contentHint: .cameraPhoto,
            sizeBytes: sizeBytes,
            createdAt: daysAgo(400),
            isProtected: protected,
            localPresence: presence
        )
    }

    /// A Cold screenshot, the `coldScreenshots` batch family.
    static func coldScreenshot(
        id: String,
        sizeBytes: UInt64? = 8 * 1024 * 1024,
        protected: Bool = false,
        presence: LocalPresence = .localAndArchived
    ) -> MediaResource {
        MediaResource(
            id: id,
            mediaType: .image,
            contentHint: .screenshot,
            sizeBytes: sizeBytes,
            createdAt: daysAgo(400),
            isProtected: protected,
            localPresence: presence
        )
    }
}
