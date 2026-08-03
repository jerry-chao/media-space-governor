import XCTest
@testable import MediaSpaceGovernorCore

final class PolicySettingsTests: XCTestCase {

    private let now = Fixtures.now

    private func screenshot(daysOld: TimeInterval) -> MediaResource {
        MediaResource(
            id: "shot-\(Int(daysOld))",
            mediaType: .image,
            contentHint: .screenshot,
            sizeBytes: 4 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(daysOld)
        )
    }

    func testAggressiveScreenshotGovernanceCoolsScreenshotsFaster() {
        let engine = GovernanceEngine(policy: .default)

        let screenshot = screenshot(daysOld: 100)
        let photo = MediaResource(
            id: "photo",
            mediaType: .image,
            contentHint: .cameraPhoto,
            sizeBytes: 4 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(100)
        )

        XCTAssertEqual(engine.applicableCoolingThreshold(screenshot), 90)
        XCTAssertEqual(engine.applicableCoolingThreshold(photo), 180)
        XCTAssertTrue(engine.isColdCandidate(screenshot, now: now))
        XCTAssertFalse(engine.isColdCandidate(photo, now: now))
    }

    func testScreenshotUsesDefaultThresholdWhenAggressiveGovernanceOff() {
        let policy = PolicySettings(aggressiveScreenshotGovernance: false)
        let engine = GovernanceEngine(policy: policy)

        let screenshot = screenshot(daysOld: 100)

        XCTAssertEqual(engine.applicableCoolingThreshold(screenshot), 180)
        XCTAssertFalse(engine.isColdCandidate(screenshot, now: now))
    }

    func testUserAdjustedCoolingThresholdChangesColdBoundary() {
        let policy = PolicySettings(coolingThresholdDays: 90)
        let engine = GovernanceEngine(policy: policy)

        let photo = MediaResource(
            id: "photo",
            mediaType: .image,
            contentHint: .cameraPhoto,
            sizeBytes: 4 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(100)
        )

        XCTAssertTrue(engine.isColdCandidate(photo, now: now))
    }
}
