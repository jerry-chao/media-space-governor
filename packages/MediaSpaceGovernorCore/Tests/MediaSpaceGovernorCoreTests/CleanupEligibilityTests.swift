import XCTest
@testable import MediaSpaceGovernorCore

final class CleanupEligibilityTests: XCTestCase {

    private let engine = GovernanceEngine(policy: .default)

    func testColdArchivedResourceIsEligibleForCleanup() {
        let resource = Fixtures.coldVideo(id: "r1")

        let eligibility = engine.cleanupEligibility(
            resource: resource,
            archiveRecord: Fixtures.archive(for: resource.id),
            now: Fixtures.now
        )

        XCTAssertEqual(eligibility, .eligibleForCleanup)
    }

    func testNoArchiveRecordBlocksCleanup() {
        let resource = Fixtures.coldVideo(id: "r2")

        let eligibility = engine.cleanupEligibility(resource: resource, archiveRecord: nil, now: Fixtures.now)

        XCTAssertEqual(eligibility, .blockedByMissingArchiveCompletion)
    }

    func testIncompleteArchiveBlocksCleanupEvenAfterUpload() {
        let resource = Fixtures.coldVideo(id: "r3")

        let eligibility = engine.cleanupEligibility(
            resource: resource,
            archiveRecord: Fixtures.archive(for: resource.id, state: .verifying),
            now: Fixtures.now
        )

        XCTAssertEqual(eligibility, .blockedByMissingArchiveCompletion)
    }

    func testWarmResourceIsBlockedByPolicy() {
        let resource = MediaResource(
            id: "r4",
            mediaType: .image,
            contentHint: .cameraPhoto,
            sizeBytes: 3 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(30),
            localPresence: .localAndArchived
        )

        let eligibility = engine.cleanupEligibility(
            resource: resource,
            archiveRecord: Fixtures.archive(for: resource.id),
            now: Fixtures.now
        )

        XCTAssertEqual(eligibility, .blockedByPolicy)
    }

    func testAlreadyCleanedResourceReportsCleanedLocally() {
        let resource = Fixtures.coldVideo(id: "r5", presence: .archivedLocalCleaned)

        let eligibility = engine.cleanupEligibility(
            resource: resource,
            archiveRecord: Fixtures.archive(for: resource.id),
            now: Fixtures.now
        )

        XCTAssertEqual(eligibility, .cleanedLocally)
    }
}
