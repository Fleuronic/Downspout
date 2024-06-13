// swift-tools-version:5.10
import PackageDescription

let package = Package(
	name: "Features",
	platforms: [
		.macOS(.v14),
	],
	products: [
		.library(
			name: "RaindropList",
			targets: ["RaindropList"]
		),
		.library(
			name: "CollectionList",
			targets: ["CollectionList"]
		),
		.library(
			name: "GroupList",
			targets: ["GroupList"]
		),
		.library(
			name: "FilterList",
			targets: ["FilterList"]
		),
		.library(
			name: "TagList",
			targets: ["TagList"]
		)
	],
	dependencies: [
		.package(name: "Models", path: "../Models"),
		.package(name: "RaindropService", path: "../Services"),
		.package(url: "https://github.com/Fleuronic/ErgoAppKit", branch: "main"),
	],
	targets: [
		.target(
			name: "RaindropList",
			dependencies: [.product(name: "Raindrop", package: "Models")]
		),
		.target(
			name: "CollectionList",
			dependencies: [
				"RaindropList",
				"RaindropService",
				"ErgoAppKit",
			]
		),
		.target(
			name: "GroupList",
			dependencies: [
				"RaindropList",
				"RaindropService",
				"ErgoAppKit",
			]
		),
		.target(
			name: "FilterList",
			dependencies: [
				"RaindropList",
				"RaindropService",
				"ErgoAppKit",
			]
		),
		.target(
			name: "TagList",
			dependencies: [
				"RaindropList",
				"RaindropService",
				"ErgoAppKit",
			]
		)
	]
)
