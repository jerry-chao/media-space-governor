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

    func testCleanupRecommendationCarriesSpaceSavingAndEligibility() {
        let resource = Fixtures.coldVideo(id: "cold-4", sizeBytes: 120 * 1024 * 1024)

        let recommendations = engine.recommendations(
            resources: [resource],
            archiveRecords: [Fixtures.archive(for: resource.id)],
            now: Fixtures.now
        )

        guard let recommendation = recommendations.first else {
            return XCTFail("expected a cleanup recommendation")
        }
        XCTAssertEqual(recommendation.action, .cleanup)
        XCTAssertEqual(recommendation.spaceSavingBytes, 120 * 1024 * 1024)
        XCTAssertEqual(recommendation.cleanupEligibility, .eligibleForCleanup)
        XCTAssertEqual(recommendation.id, "cleanup-cold-4")
    }

    func testArchiveRecommendationCarriesNoSpaceSaving() {
        let resource = Fixtures.coldVideo(id: "cold-5")

        let recommendations = engine.recommendations(
            resources: [resource],
            archiveRecords: [],
            now: Fixtures.now
        )

        guard let recommendation = recommendations.first else {
            return XCTFail("expected an archive recommendation")
        }
        XCTAssertEqual(recommendation.action, .archive)
        XCTAssertEqual(recommendation.spaceSavingBytes, 0)
        XCTAssertNil(recommendation.cleanupEligibility)
        XCTAssertEqual(recommendation.id, "archive-cold-5")
    }

    func testResourceBeingRestoredGetsNoRecommendation() {
        let resource = Fixtures.coldVideo(id: "cold-6", presence: .restoreInProgress)

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
