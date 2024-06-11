// swift-tools-version:5.10
import PackageDescription

let package = Package(
	name: "Features",
	platforms: [
		.macOS(.v14),
	],
	products: [
		.library(
			name: "GroupList",
			targets: ["GroupList"]
		),
		.library(
			name: "TagList",
			targets: ["TagList"]
		)
	],
	dependencies: [
		.package(name: "RaindropService", path: "../Services"),
		.package(url: "https://github.com/Fleuronic/ErgoAppKit", branch: "main"),
	],
	targets: [
		.target(
			name: "GroupList",
			dependencies: [
				"RaindropService",
				"ErgoAppKit",
			]
		),.target(
			name: "TagList",
			dependencies: [
				"RaindropService",
				"ErgoAppKit",
			]
		)
	]
)
