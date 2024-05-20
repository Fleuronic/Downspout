// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Features",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "Group",
            targets: ["Group"]
        ),
    ],
    dependencies: [
        .package(name: "Raindrop", path: "../Models"),
        .package(url: "https://github.com/Fleuronic/ErgoAppKit", branch: "main"),
    ],
    targets: [
        .target(
            name: "Group",
            dependencies: [
				"Raindrop",
                "ErgoAppKit",
            ]
        ),
    ]
)
