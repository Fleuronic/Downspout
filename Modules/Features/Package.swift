// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Features",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "GroupList",
            targets: ["GroupList"]
        ),
    ],
    dependencies: [
        .package(name: "Raindrop", path: "../Models"),
        .package(url: "https://github.com/Fleuronic/ErgoAppKit", branch: "main"),
    ],
    targets: [
        .target(
            name: "GroupList",
            dependencies: [
				"Raindrop",
                "ErgoAppKit",
            ]
        ),
    ]
)
