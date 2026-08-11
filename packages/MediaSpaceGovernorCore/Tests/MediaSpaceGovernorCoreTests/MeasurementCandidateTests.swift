import XCTest
@testable import MediaSpaceGovernorCore

/// Ticket 03: only non-Protected Cold Resources that are still present locally
/// qualify for local-original size measurement.
final class MeasurementCandidateTests: XCTestCase {

    func testColdUnprotectedLocalResourceIsCandidate() {
        let resource = Fixtures.coldVideo(id: "r1", presence: .localOnly)

        let candidates = GovernanceEngine()
            .measurementCandidates(resources: [resource], now: Fixtures.now)

        XCTAssertEqual(candidates.map(\.id), ["r1"])
    }

    func testProtectedColdResourceIsNotCandidate() {
        let resource = Fixtures.coldVideo(id: "r2", protected: true)

        XCTAssertTrue(
            GovernanceEngine().measurementCandidates(resources: [resource], now: Fixtures.now).isEmpty
        )
    }

    func testWarmResourceIsNotCandidate() {
        let resource = MediaResource(
            id: "r3",
            mediaType: .image,
            contentHint: .cameraPhoto,
            sizeBytes: nil,
            createdAt: Fixtures.daysAgo(400),
            lastViewedAt: Fixtures.daysAgo(2)
        )

        XCTAssertTrue(
            GovernanceEngine().measurementCandidates(resources: [resource], now: Fixtures.now).isEmpty
        )
    }

    func testColdResourceNotLocallyPresentIsNotCandidate() {
        let resource = Fixtures.coldVideo(id: "r4", presence: .archivedLocalCleaned)

        XCTAssertTrue(
            GovernanceEngine().measurementCandidates(resources: [resource], now: Fixtures.now).isEmpty
        )
    }
}
