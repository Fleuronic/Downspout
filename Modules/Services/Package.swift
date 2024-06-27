// swift-tools-version:5.10
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
				"RaindropAPI",
				"RaindropDatabase",
				"RaindropService"
			]
		),
	],
	dependencies: [
		.package(name: "Models", path: "../Models"),
		.package(path: "../../../Dewdrop/Submodules/DewdropAPI"),
		.package(path: "../../../Dewdrop/Submodules/DewdropDatabase"),
		.package(url: "https://github.com/Fleuronic/Ergo.git", branch: "main"),
		.package(url: "https://github.com/Fleuronic/URL", branch: "main"),
		.package(url: "https://github.com/granoff/Strongbox", from: "0.6.1"),
		.package(url: "https://github.com/groue/Semaphore", branch: "main")
	],
	targets: [
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
				"Strongbox",
				"DewdropDatabase",
				"RaindropService",
			],
			path: "Sources/Raindrop/Clients/Database"
		),
		.testTarget(
			name: "RaindropDatabaseTests",
			dependencies: ["RaindropDatabase"],
			path: "Tests/Raindrop/Clients/Database"
		),
		.target(
			name: "RaindropService",
			dependencies: [
				"Ergo",
				"Semaphore",
				.product(name: "Raindrop", package: "Models"),
			],
			path: "Sources/Raindrop/Service"
		)
	]
)
