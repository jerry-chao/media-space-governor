import XCTest
@testable import MediaSpaceGovernorCore

/// Pins the phase-1 record shapes to the design's Suggested Local Data Model.
final class RecordShapesTests: XCTestCase {

    func testLocalPresenceIncludesRestoreStates() {
        XCTAssertTrue(LocalPresence.allCases.contains(.restoreInProgress))
        XCTAssertTrue(LocalPresence.allCases.contains(.restoreFailed))
    }

    func testArchiveRecordCarriesDesignReconciliationFieldsWithNilDefaults() {
        let record = ArchiveRecord(id: "a1", resourceID: "r1", archiveState: .archiveComplete, remoteObjectID: "obj-1")

        XCTAssertNil(record.integrityVerified)
        XCTAssertNil(record.restoreAvailable)
        XCTAssertNil(record.lastSyncedAt)
        XCTAssertEqual(record.remoteObjectID, "obj-1")
    }

    func testBatchCarriesRequiredCleanupAction() {
        let batch = GovernanceBatch(
            id: "b1",
            batchType: .coldCameraPhotos,
            action: .cleanup,
            resourceIDs: ["r1"],
            totalSpaceSavingBytes: 4 * 1024 * 1024
        )

        XCTAssertEqual(batch.action, .cleanup)
    }

    func testMediaResourceExposesEvidenceAndPresenceFacts() {
        let resource = MediaResource(
            id: "r1",
            mediaType: .image,
            contentHint: .cameraPhoto,
            sizeBytes: 100,
            createdAt: Fixtures.daysAgo(400),
            lastViewedAt: Fixtures.daysAgo(2)
        )

        XCTAssertTrue(resource.isLocallyPresent)
        XCTAssertTrue(resource.hasUsageEvidence)
        XCTAssertEqual(resource.usageEvidenceDates, [resource.lastViewedAt])
    }
}
