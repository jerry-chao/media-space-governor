import XCTest
@testable import MediaSpaceGovernorCore

/// Ticket 02: mapping normalized library facts to MediaResources must follow
/// the shallow Classification rules and exclude hidden items.
final class LibraryInventoryTests: XCTestCase {

    private func item(
        id: String,
        mediaType: MediaType,
        isScreenshot: Bool = false,
        isFavorite: Bool = false,
        isHidden: Bool = false
    ) -> LibraryInventoryItem {
        LibraryInventoryItem(
            id: id,
            mediaType: mediaType,
            isScreenshot: isScreenshot,
            isFavorite: isFavorite,
            isHidden: isHidden,
            createdAt: Fixtures.daysAgo(10)
        )
    }

    func testScreenshotItemMapsToScreenshotContentHint() {
        let resource = LibraryInventory.resource(for: item(id: "s1", mediaType: .image, isScreenshot: true))

        XCTAssertEqual(resource?.contentHint, .screenshot)
        XCTAssertEqual(resource?.mediaType, .image)
    }

    func testCameraPhotoItemMapsToCameraPhotoContentHint() {
        let resource = LibraryInventory.resource(for: item(id: "p1", mediaType: .image))

        XCTAssertEqual(resource?.contentHint, .cameraPhoto)
    }

    func testVideoItemMapsToOrdinaryVideoContentHint() {
        let resource = LibraryInventory.resource(for: item(id: "v1", mediaType: .video))

        XCTAssertEqual(resource?.contentHint, .ordinaryVideo)
        XCTAssertEqual(resource?.mediaType, .video)
    }

    func testFavoriteItemMapsToProtectedResource() {
        let resource = LibraryInventory.resource(for: item(id: "f1", mediaType: .image, isFavorite: true))

        XCTAssertEqual(resource?.isProtected, true)
    }

    func testHiddenItemIsExcluded() {
        let resource = LibraryInventory.resource(for: item(id: "h1", mediaType: .image, isHidden: true))

        XCTAssertNil(resource)
    }

    func testMappedResourceIsUnmeasuredUntilMeasured() {
        let resource = LibraryInventory.resource(for: item(id: "u1", mediaType: .video))

        XCTAssertNil(resource?.sizeBytes)
    }
}
