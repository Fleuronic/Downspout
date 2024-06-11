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
				"RaindropService",
				"RaindropAPI",
			]
		),
	],
	dependencies: [
		.package(name: "Models", path: "../Models"),
		.package(path: "../../../Dewdrop/Submodules/DewdropAPI"),
		.package(url: "https://github.com/Fleuronic/Ergo.git", branch: "main")
	],
	targets: [
		.target(
			name: "RaindropService",
			dependencies: [
				.product(name: "Raindrop", package: "Models"),
				"Ergo"
			],
			path: "Sources/Raindrop/Service"
		),
		.target(
			name: "RaindropAPI",
			dependencies: [
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
	]
)
