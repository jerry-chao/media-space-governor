import XCTest
@testable import MediaSpaceGovernorCore

final class GovernanceBatchTests: XCTestCase {

    private let engine = GovernanceEngine(policy: .default)

    private func coldVideo(id: String, sizeMB: UInt64) -> MediaResource {
        MediaResource(
            id: id,
            mediaType: .video,
            contentHint: .ordinaryVideo,
            sizeBytes: sizeMB * 1024 * 1024,
            createdAt: Fixtures.daysAgo(400),
            localPresence: .localAndArchived
        )
    }

    func testLargeColdVideosGroupIntoSingleBatchWithSummedSavings() {
        let resources = [coldVideo(id: "v1", sizeMB: 200), coldVideo(id: "v2", sizeMB: 150)]
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

    func testOldArchivedCameraPhotoFormsBatch() {
        let photo = MediaResource(
            id: "p1",
            mediaType: .image,
            contentHint: .cameraPhoto,
            sizeBytes: 5 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(400),
            localPresence: .localAndArchived
        )

        let batches = engine.batches(
            resources: [photo],
            archiveRecords: [Fixtures.archive(for: photo.id)],
            now: Fixtures.now
        )

        XCTAssertEqual(batches.count, 1)
        XCTAssertEqual(batches.first?.batchType, .oldArchivedImages)
    }

    func testColdResourceWithoutArchiveCompletionDoesNotEnterCleanupBatch() {
        let video = coldVideo(id: "v3", sizeMB: 200)

        let batches = engine.batches(resources: [video], archiveRecords: [], now: Fixtures.now)

        XCTAssertTrue(batches.isEmpty)
    }

    func testProtectedColdArchivedVideoIsExcludedFromBatches() {
        let video = MediaResource(
            id: "v4",
            mediaType: .video,
            contentHint: .ordinaryVideo,
            sizeBytes: 200 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(400),
            isProtected: true,
            localPresence: .localAndArchived
        )

        let batches = engine.batches(
            resources: [video],
            archiveRecords: [Fixtures.archive(for: video.id)],
            now: Fixtures.now
        )

        XCTAssertTrue(batches.isEmpty)
    }

    func testDisablingLargeVideoPreferenceDropsLargeVideoBatch() {
        let video = coldVideo(id: "v5", sizeMB: 200)
        let engine = GovernanceEngine(policy: PolicySettings(preferLargeVideoGovernance: false))

        let batches = engine.batches(
            resources: [video],
            archiveRecords: [Fixtures.archive(for: video.id)],
            now: Fixtures.now
        )

        XCTAssertTrue(batches.isEmpty)
    }

    func testAlreadyCleanedResourceDoesNotFormCleanupBatch() {
        let video = MediaResource(
            id: "v6",
            mediaType: .video,
            contentHint: .ordinaryVideo,
            sizeBytes: 200 * 1024 * 1024,
            createdAt: Fixtures.daysAgo(400),
            localPresence: .archivedLocalCleaned
        )

        let batches = engine.batches(
            resources: [video],
            archiveRecords: [Fixtures.archive(for: video.id)],
            now: Fixtures.now
        )

        XCTAssertTrue(batches.isEmpty)
    }

    func testSmallColdVideoIsNotGroupedIntoCleanupBatch() {
        let video = coldVideo(id: "v7", sizeMB: 20)

        let batches = engine.batches(
            resources: [video],
            archiveRecords: [Fixtures.archive(for: video.id)],
            now: Fixtures.now
        )

        XCTAssertTrue(batches.isEmpty)
    }
}
