import XCTest
@testable import MediaSpaceGovernorCore

final class GovernanceBatchTests: XCTestCase {

    private let engine = GovernanceEngine(policy: .default)

    func testLargeColdVideosGroupIntoSingleBatchWithSummedSavings() {
        let resources = [
            Fixtures.coldVideo(id: "v1", sizeBytes: 200 * 1024 * 1024),
            Fixtures.coldVideo(id: "v2", sizeBytes: 150 * 1024 * 1024)
        ]
        let archives = resources.map { Fixtures.archive(for: $0.id) }

        let batches = engine.batches(resources: resources, archiveRecords: archives, now: Fixtures.now)

        XCTAssertEqual(batches.count, 1)
        XCTAssertEqual(batches.first?.batchType, .largeColdVideos)
        XCTAssertEqual(batches.first?.resourceIDs, ["v1", "v2"])
        XCTAssertEqual(batches.first?.totalSpaceSavingBytes, 350 * 1024 * 1024)
    }

    func testColdScreenshotFormsBatch() {
        let screenshot = MediaResource(
            id: "s1",
            mediaType: .image,
            contentHint: .screenshot,
            sizeBytes: 8 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(400),
            localPresence: .localAndArchived
        )

        let batches = engine.batches(
            resources: [screenshot],
            archiveRecords: [Fixtures.archive(for: screenshot.id)],
            now: Fixtures.now
        )

        XCTAssertEqual(batches.count, 1)
        XCTAssertEqual(batches.first?.batchType, .coldScreenshots)
        XCTAssertEqual(batches.first?.resourceIDs, ["s1"])
    }

    func testColdCameraPhotoFormsBatch() {
        let photo = Fixtures.coldCameraPhoto(id: "p1", sizeBytes: 5 * 1024 * 1024)

        let batches = engine.batches(
            resources: [photo],
            archiveRecords: [Fixtures.archive(for: photo.id)],
            now: Fixtures.now
        )

        XCTAssertEqual(batches.count, 1)
        XCTAssertEqual(batches.first?.batchType, .coldCameraPhotos)
    }

    func testColdResourceWithoutArchiveCompletionDoesNotEnterCleanupBatch() {
        let video = Fixtures.coldVideo(id: "v3", sizeBytes: 200 * 1024 * 1024)

        let batches = engine.batches(resources: [video], archiveRecords: [], now: Fixtures.now)

        XCTAssertTrue(batches.isEmpty)
    }

    func testProtectedColdArchivedVideoIsExcludedFromBatches() {
        let video = Fixtures.coldVideo(id: "v4", sizeBytes: 200 * 1024 * 1024, protected: true)

        let batches = engine.batches(
            resources: [video],
            archiveRecords: [Fixtures.archive(for: video.id)],
            now: Fixtures.now
        )

        XCTAssertTrue(batches.isEmpty)
    }

    func testDisablingLargeVideoPreferenceDropsLargeVideoBatch() {
        let video = Fixtures.coldVideo(id: "v5", sizeBytes: 200 * 1024 * 1024)
        let engine = GovernanceEngine(policy: PolicySettings(preferLargeVideoGovernance: false))

        let batches = engine.batches(
            resources: [video],
            archiveRecords: [Fixtures.archive(for: video.id)],
            now: Fixtures.now
        )

        XCTAssertTrue(batches.isEmpty)
    }

    func testAlreadyCleanedResourceDoesNotFormCleanupBatch() {
        let video = Fixtures.coldVideo(id: "v6", sizeBytes: 200 * 1024 * 1024, presence: .archivedLocalCleaned)

        let batches = engine.batches(
            resources: [video],
            archiveRecords: [Fixtures.archive(for: video.id)],
            now: Fixtures.now
        )

        XCTAssertTrue(batches.isEmpty)
    }

    func testSmallColdVideoIsNotGroupedIntoCleanupBatch() {
        let video = Fixtures.coldVideo(id: "v7", sizeBytes: 20 * 1024 * 1024)

        let batches = engine.batches(
            resources: [video],
            archiveRecords: [Fixtures.archive(for: video.id)],
            now: Fixtures.now
        )

        XCTAssertTrue(batches.isEmpty)
    }
}
