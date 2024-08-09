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
				"RaindropAPI",
				"RaindropDatabase",
				"RaindropService"
			]
		),
	],
	dependencies: [
		.package(name: "Models", path: "../Models"),
		.package(url: "https://github.com/Fleuronic/DewdropAPI.git", branch: "main"),
		.package(url: "https://github.com/Fleuronic/DewdropDatabase.git", branch: "main"),
		.package(url: "https://github.com/Fleuronic/URL", branch: "main"),
		.package(url: "https://github.com/Fleuronic/Ergo.git", branch: "main"),
		.package(url: "https://github.com/Fleuronic/Catenary", branch: "main"),
		.package(url: "https://github.com/Fleuronic/Catenoid", branch: "main"),
		.package(url: "https://github.com/Fleuronic/Semaphore", branch: "main")
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
				"DewdropDatabase",
				"RaindropService"
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
				"Catenary",
				"Catenoid",
				"Semaphore",
				.product(name: "Raindrop", package: "Models"),
			],
			path: "Sources/Raindrop/Service"
		)
	],
	swiftLanguageVersions: [.v6]
)
