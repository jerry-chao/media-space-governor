import XCTest
@testable import MediaSpaceGovernorCore

/// Ticket 01: an unmeasured local original must never be presented as a
/// zero-byte Space Saving Opportunity and must not enter storage-impact totals.
final class UnmeasuredSizeTests: XCTestCase {

    func testCleanupRecommendationHasNilSavingWhenSizeUnmeasured() {
        let engine = GovernanceEngine()
        let resource = Fixtures.coldVideo(id: "r1", sizeBytes: nil)

        let cleanup = engine.recommendations(
            resources: [resource],
            archiveRecords: [Fixtures.archive(for: "r1")],
            now: Fixtures.now
        ).first { $0.action == .cleanup }

        XCTAssertNotNil(cleanup)
        XCTAssertNil(cleanup?.spaceSavingBytes)
    }

    func testCleanupRecommendationCarriesMeasuredSaving() {
        let engine = GovernanceEngine()
        let resource = Fixtures.coldVideo(id: "r2", sizeBytes: 200 * 1024 * 1024)

        let cleanup = engine.recommendations(
            resources: [resource],
            archiveRecords: [Fixtures.archive(for: "r2")],
            now: Fixtures.now
        ).first { $0.action == .cleanup }

        XCTAssertEqual(cleanup?.spaceSavingBytes, 200 * 1024 * 1024)
    }

    func testArchiveRecommendationReportsZeroLocalSavingEvenWhenSizeUnmeasured() {
        let engine = GovernanceEngine()
        let resource = Fixtures.coldVideo(id: "r3", sizeBytes: nil, presence: .localOnly)

        let archive = engine.recommendations(
            resources: [resource],
            archiveRecords: [],
            now: Fixtures.now
        ).first { $0.action == .archive }

        XCTAssertEqual(archive?.spaceSavingBytes, 0)
    }

    func testBatchTotalSumsOnlyMeasuredSizes() {
        let engine = GovernanceEngine()
        let measured = Fixtures.coldCameraPhoto(id: "p1", sizeBytes: 4 * 1024 * 1024)
        let unmeasured = Fixtures.coldCameraPhoto(id: "p2", sizeBytes: nil)

        let cameraBatch = engine.batches(
            resources: [measured, unmeasured],
            archiveRecords: [Fixtures.archive(for: "p1"), Fixtures.archive(for: "p2")],
            now: Fixtures.now
        ).first { $0.batchType == .coldCameraPhotos }

        XCTAssertEqual(cameraBatch?.resourceIDs, ["p1", "p2"])
        XCTAssertEqual(cameraBatch?.totalSpaceSavingBytes, 4 * 1024 * 1024)
    }

    func testLargeVideoBatchExcludesUnmeasuredVideo() {
        let engine = GovernanceEngine()
        let unmeasured = Fixtures.coldVideo(id: "v1", sizeBytes: nil)

        let batches = engine.batches(
            resources: [unmeasured],
            archiveRecords: [Fixtures.archive(for: "v1")],
            now: Fixtures.now
        )

        XCTAssertFalse(batches.contains { $0.batchType == .largeColdVideos })
    }

    func testMeasuredLargeVideoEntersLargeVideoBatch() {
        let engine = GovernanceEngine()
        let measured = Fixtures.coldVideo(id: "v2", sizeBytes: 300 * 1024 * 1024)

        let batches = engine.batches(
            resources: [measured],
            archiveRecords: [Fixtures.archive(for: "v2")],
            now: Fixtures.now
        )

        XCTAssertTrue(batches.contains { $0.batchType == .largeColdVideos })
    }
}
