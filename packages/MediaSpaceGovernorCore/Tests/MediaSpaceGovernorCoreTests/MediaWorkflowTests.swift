import XCTest
@testable import MediaSpaceGovernorCore

final class MediaWorkflowTests: XCTestCase {

    private let workflow = MediaWorkflow(engine: GovernanceEngine(policy: .default))

    func testConfirmedCleanupOfEligibleResourceRemovesLocalPrimary() throws {
        let resource = Fixtures.coldVideo(id: "r1", sizeBytes: 200 * 1024 * 1024)
        let archive = Fixtures.archive(for: resource.id)

        let cleaned = try workflow.confirmCleanup(
            of: resource,
            archiveRecord: archive,
            now: Fixtures.now
        )

        XCTAssertEqual(cleaned.localPresence, .archivedLocalCleaned)
        XCTAssertEqual(cleaned.id, resource.id)
    }

    func testCleanupWithoutArchiveCompletionIsBlocked() {
        let resource = Fixtures.coldVideo(id: "r2", sizeBytes: 200 * 1024 * 1024)

        XCTAssertThrowsError(
            try workflow.confirmCleanup(of: resource, archiveRecord: nil, now: Fixtures.now)
        ) { error in
            XCTAssertEqual(error as? GovernanceError, .cleanupBlocked(.blockedByMissingArchiveCompletion))
        }
    }

    func testCleanupOfProtectedResourceIsBlocked() {
        let resource = Fixtures.coldVideo(id: "r3", sizeBytes: 200 * 1024 * 1024, protected: true)
        let archive = Fixtures.archive(for: resource.id)

        XCTAssertThrowsError(
            try workflow.confirmCleanup(of: resource, archiveRecord: archive, now: Fixtures.now)
        ) { error in
            XCTAssertEqual(error as? GovernanceError, .cleanupBlocked(.blockedAsProtectedResource))
        }
    }

    func testRestoreReturnsCleanedResourceToLocal() throws {
        let cleaned = Fixtures.coldVideo(id: "r4", sizeBytes: 200 * 1024 * 1024, presence: .archivedLocalCleaned)
        let archive = Fixtures.archive(for: cleaned.id)

        let restored = try workflow.restore(cleaned, archiveRecord: archive)

        XCTAssertEqual(restored.localPresence, .localAndArchived)
    }

    func testRestoreWithoutArchiveCompletionIsBlocked() {
        let cleaned = Fixtures.coldVideo(id: "r5", sizeBytes: 200 * 1024 * 1024, presence: .archivedLocalCleaned)

        XCTAssertThrowsError(
            try workflow.restore(cleaned, archiveRecord: nil)
        ) { error in
            XCTAssertEqual(error as? GovernanceError, .restoreBlocked)
        }
    }
}
