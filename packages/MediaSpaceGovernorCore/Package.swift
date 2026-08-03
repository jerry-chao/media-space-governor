// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MediaSpaceGovernorCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "MediaSpaceGovernorCore", targets: ["MediaSpaceGovernorCore"]),
    ],
    targets: [
        .target(name: "MediaSpaceGovernorCore"),
        .testTarget(
            name: "MediaSpaceGovernorCoreTests",
            dependencies: ["MediaSpaceGovernorCore"]
        ),
    ]
)
