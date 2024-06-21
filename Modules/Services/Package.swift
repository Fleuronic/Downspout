// swift-tools-version:6.0
import PackageDescription

let package = Package(
	name: "Services",
	platforms: [
		.macOS(.v12)
	],
	products: [
		.library(
			name: "RaindropService",
			targets: [
				"RaindropService",
				"RaindropAPI",
				"RaindropDatabase"
			]
		),
	],
	dependencies: [
		.package(name: "Models", path: "../Models"),
		.package(path: "../../../Dewdrop/Submodules/DewdropAPI"),
		.package(url: "https://github.com/Fleuronic/Ergo.git", branch: "main"),
		.package(url: "https://github.com/Fleuronic/Catena.git", branch: "main"),
		.package(url: "https://github.com/Fleuronic/URL", branch: "swift-6"),
		.package(url: "https://github.com/granoff/Strongbox", from: "0.6.1"),
		.package(url: "https://github.com/groue/Semaphore", branch: "main")
	],
	targets: [
		.target(
			name: "RaindropService",
			dependencies: [
				"Ergo",
				"Catena",
				"Semaphore",
				.product(name: "Raindrop", package: "Models"),
			],
			path: "Sources/Raindrop/Service"
		),
		.target(
			name: "RaindropAPI",
			dependencies: [
				"URL",
				"DewdropAPI",
				"RaindropService"
			],
			path: "Sources/Raindrop/Clients/API"
		),
		.testTarget(
			name: "RaindropAPITests",
			dependencies: ["RaindropAPI"],
			path: "Tests/Raindrop/Clients/API"
		),
		.target(
			name: "RaindropDatabase",
			dependencies: [
				"RaindropService",
				"Strongbox"
			],
			path: "Sources/Raindrop/Clients/Database"
		),
		.testTarget(
			name: "RaindropDatabaseTests",
			dependencies: ["RaindropDatabase"],
			path: "Tests/Raindrop/Clients/Database"
		)
	],
	swiftLanguageVersions: [.v6]
)
