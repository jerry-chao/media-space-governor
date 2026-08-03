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
}
