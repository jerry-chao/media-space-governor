import XCTest
@testable import MediaSpaceGovernorCore

final class ProtectedResourceTests: XCTestCase {

    private let engine = GovernanceEngine(policy: .default)

    private func coldProtectedResource() -> MediaResource {
        MediaResource(
            id: "protected-1",
            mediaType: .image,
            contentHint: .cameraPhoto,
            sizeBytes: 4 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(400),
            isProtected: true,
            localPresence: .localAndArchived
        )
    }

    func testProtectedColdResourceIsStillClassifiedAsCold() {
        let state = engine.classify(coldProtectedResource(), archiveRecord: Fixtures.archive(for: "protected-1"), now: Fixtures.now)

        XCTAssertTrue(state.isColdCandidate)
        XCTAssertTrue(state.isProtected)
    }

    func testProtectedResourceNeverReceivesArchiveOrCleanupRecommendation() {
        let resource = coldProtectedResource()

        let recommendations = engine.recommendations(
            resources: [resource],
            archiveRecords: [Fixtures.archive(for: resource.id)],
            now: Fixtures.now
        )

        XCTAssertTrue(recommendations.isEmpty)
    }

    func testProtectedArchivedResourceIsBlockedFromCleanup() {
        let resource = coldProtectedResource()

        let eligibility = engine.cleanupEligibility(
            resource: resource,
            archiveRecord: Fixtures.archive(for: resource.id),
            now: Fixtures.now
        )

        XCTAssertEqual(eligibility, .blockedAsProtectedResource)
    }

    func testColdUnarchivedResourceGetsArchiveRecommendation() {
        let resource = MediaResource(
            id: "cold-1",
            mediaType: .video,
            contentHint: .ordinaryVideo,
            sizeBytes: 50 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(400)
        )

        let recommendations = engine.recommendations(
            resources: [resource],
            archiveRecords: [],
            now: Fixtures.now
        )

        XCTAssertEqual(recommendations.map(\.action), [.archive])
        XCTAssertEqual(recommendations.map(\.resourceID), [resource.id])
    }

    func testColdArchivedResourceGetsCleanupRecommendation() {
        let resource = MediaResource(
            id: "cold-2",
            mediaType: .video,
            contentHint: .ordinaryVideo,
            sizeBytes: 50 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(400),
            localPresence: .localAndArchived
        )

        let recommendations = engine.recommendations(
            resources: [resource],
            archiveRecords: [Fixtures.archive(for: resource.id)],
            now: Fixtures.now
        )

        XCTAssertEqual(recommendations.map(\.action), [.cleanup])
    }

    func testActiveResourceGetsNoRecommendation() {
        let resource = MediaResource(
            id: "active-1",
            mediaType: .image,
            contentHint: .cameraPhoto,
            sizeBytes: 3 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(5)
        )

        let recommendations = engine.recommendations(
            resources: [resource],
            archiveRecords: [Fixtures.archive(for: resource.id)],
            now: Fixtures.now
        )

        XCTAssertTrue(recommendations.isEmpty)
    }
}
