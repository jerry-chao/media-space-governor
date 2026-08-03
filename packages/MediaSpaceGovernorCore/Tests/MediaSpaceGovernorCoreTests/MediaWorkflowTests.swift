import XCTest
@testable import MediaSpaceGovernorCore

final class MediaWorkflowTests: XCTestCase {

    private let workflow = MediaWorkflow(engine: GovernanceEngine(policy: .default))

    private func coldVideo(id: String, protected: Bool = false, presence: LocalPresence = .localAndArchived) -> MediaResource {
        MediaResource(
            id: id,
            mediaType: .video,
            contentHint: .ordinaryVideo,
            sizeBytes: 200 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(400),
            isProtected: protected,
            localPresence: presence
        )
    }

    func testConfirmedCleanupOfEligibleResourceRemovesLocalPrimary() throws {
        let resource = coldVideo(id: "r1")
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
        let resource = coldVideo(id: "r2")

        XCTAssertThrowsError(
            try workflow.confirmCleanup(of: resource, archiveRecord: nil, now: Fixtures.now)
        ) { error in
            XCTAssertEqual(error as? GovernanceError, .cleanupBlocked(.blockedByMissingArchiveCompletion))
        }
    }

    func testCleanupOfProtectedResourceIsBlocked() {
        let resource = coldVideo(id: "r3", protected: true)
        let archive = Fixtures.archive(for: resource.id)

        XCTAssertThrowsError(
            try workflow.confirmCleanup(of: resource, archiveRecord: archive, now: Fixtures.now)
        ) { error in
            XCTAssertEqual(error as? GovernanceError, .cleanupBlocked(.blockedAsProtectedResource))
        }
    }

    func testRestoreReturnsCleanedResourceToLocal() {
        let cleaned = coldVideo(id: "r4", presence: .archivedLocalCleaned)

        let restored = workflow.restore(cleaned)

        XCTAssertEqual(restored.localPresence, .localAndArchived)
    }
}
