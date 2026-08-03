import XCTest
@testable import MediaSpaceGovernorCore

final class ProtectedResourceTests: XCTestCase {

    private let engine = GovernanceEngine(policy: .default)

    private func protectedResource() -> MediaResource {
        Fixtures.coldCameraPhoto(id: "protected-1", protected: true)
    }

    func testProtectedColdResourceIsStillClassifiedAsCold() {
        let state = engine.classify(protectedResource(), archiveRecord: Fixtures.archive(for: "protected-1"), now: Fixtures.now)

        XCTAssertTrue(state.isColdCandidate)
        XCTAssertTrue(state.isProtected)
    }

    func testProtectedResourceNeverReceivesArchiveOrCleanupRecommendation() {
        let resource = protectedResource()

        let recommendations = engine.recommendations(
            resources: [resource],
            archiveRecords: [Fixtures.archive(for: resource.id)],
            now: Fixtures.now
        )

        XCTAssertTrue(recommendations.isEmpty)
    }

    func testProtectedArchivedResourceIsBlockedFromCleanup() {
        let resource = protectedResource()

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

    func testAlreadyCleanedColdResourceGetsNoCleanupRecommendation() {
        let resource = Fixtures.coldVideo(id: "cold-3", presence: .archivedLocalCleaned)

        let recommendations = engine.recommendations(
            resources: [resource],
            archiveRecords: [Fixtures.archive(for: resource.id)],
            now: Fixtures.now
        )

        XCTAssertTrue(recommendations.isEmpty)
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
