import XCTest
@testable import MediaSpaceGovernorCore

final class ColdResourceClassificationTests: XCTestCase {

    private let engine = GovernanceEngine(policy: .default)

    func testOldVideoWithNoUsageEvidenceIsColdCandidate() {
        let video = MediaResource(
            id: "v1",
            mediaType: .video,
            contentHint: .ordinaryVideo,
            sizeBytes: 200 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(365)
        )

        XCTAssertTrue(engine.isColdCandidate(video, now: Fixtures.now))
        XCTAssertEqual(engine.usageHeat(video, now: Fixtures.now), .cold)
    }

    func testRecentlyCreatedResourceIsActiveNotCold() {
        let photo = MediaResource(
            id: "p1",
            mediaType: .image,
            contentHint: .cameraPhoto,
            sizeBytes: 3 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(7)
        )

        XCTAssertFalse(engine.isColdCandidate(photo, now: Fixtures.now))
        XCTAssertEqual(engine.usageHeat(photo, now: Fixtures.now), .active)
    }

    func testOldResourceViewedRecentlyIsActiveNotCold() {
        let video = MediaResource(
            id: "v2",
            mediaType: .video,
            contentHint: .ordinaryVideo,
            sizeBytes: 50 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(365),
            lastViewedAt: Fixtures.daysAgo(3)
        )

        XCTAssertFalse(engine.isColdCandidate(video, now: Fixtures.now))
        XCTAssertEqual(engine.usageHeat(video, now: Fixtures.now), .active)
    }

    func testResourceWithStaleUsageEvidenceIsLukewarmNotCold() {
        let photo = MediaResource(
            id: "p2",
            mediaType: .image,
            contentHint: .cameraPhoto,
            sizeBytes: 2 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(400),
            lastViewedAt: Fixtures.daysAgo(200)
        )

        XCTAssertFalse(engine.isColdCandidate(photo, now: Fixtures.now))
        XCTAssertEqual(engine.usageHeat(photo, now: Fixtures.now), .lukewarm)
    }
}
