// swift-tools-version:5.10
import PackageDescription

let package = Package(
	name: "Features",
	platforms: [
		.macOS(.v14),
	],
	products: [
		.library(
			name: "Root",
			targets: ["Root"]
		),
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
		),
		.library(
			name: "Settings",
			targets: ["Settings"]
		)
	],
	dependencies: [
		.package(name: "Models", path: "../Models"),
		.package(name: "RaindropService", path: "../Services"),
		.package(url: "https://github.com/Fleuronic/ErgoAppKit", branch: "main"),
		.package(url: "https://github.com/Fleuronic/workflow-swift", branch: "main"),
		.package(url: "https://github.com/Fleuronic/EnumKit", branch: "master"),
		.package(url: "https://github.com/sparrowcode/SafeSFSymbols", branch: "main"),
		.package(url: "https://github.com/mixpanel/mixpanel-swift", branch: "master"),
		.package(url: "https://github.com/bugsnag/bugsnag-cocoa", exact: "6.30.1")
	],
	targets: [
		.target(
			name: "Root",
			dependencies: [
				"GroupList",
				"CollectionList",
				"FilterList",
				"TagList",
				"Settings",
				.product(name: "WorkflowContainers", package: "workflow-swift"),
				.product(name: "Mixpanel", package: "mixpanel-swift"),
				.product(name: "Bugsnag", package: "bugsnag-cocoa")
			]
		),
		.target(
			name: "RaindropList",
			dependencies: [
				"SafeSFSymbols",
				.product(name: "Raindrop", package: "Models")
			]
		),
		.target(
			name: "CollectionList",
			dependencies: [
				"RaindropList",
				"RaindropService",
				"ErgoAppKit",
				"SafeSFSymbols",
				.product(name: "WorkflowContainers", package: "workflow-swift")
			]
		),
		.target(
			name: "GroupList",
			dependencies: [
				"RaindropList",
				"RaindropService",
				"ErgoAppKit",
				"EnumKit",
				"SafeSFSymbols",
				.product(name: "WorkflowContainers", package: "workflow-swift")
			]
		),
		.target(
			name: "FilterList",
			dependencies: [
				"RaindropList",
				"RaindropService",
				"ErgoAppKit",
				"SafeSFSymbols",
				.product(name: "WorkflowContainers", package: "workflow-swift")
			]
		),
		.target(
			name: "TagList",
			dependencies: [
				"RaindropList",
				"RaindropService",
				"ErgoAppKit",
				"SafeSFSymbols",
				.product(name: "WorkflowContainers", package: "workflow-swift")
			]
		),
		.target(
			name: "Settings",
			dependencies: [
				"RaindropService",
				"ErgoAppKit",
				"EnumKit",
				"SafeSFSymbols",
				.product(name: "WorkflowContainers", package: "workflow-swift"),
			]
		)
	]
)
