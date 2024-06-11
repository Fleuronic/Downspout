// swift-tools-version:5.10
import PackageDescription

let package = Package(
	name: "Models",
	platforms: [
		.macOS(.v12),
	],
	products: [
		.library(
			name: "Raindrop",
			targets: ["Raindrop"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/Fleuronic/InitMacro.git", branch: "update-swift-syntax"),
		.package(url: "https://github.com/Fleuronic/DewdropService", branch: "main")
	],
	targets: [
		.target(
			name: "Raindrop",
			dependencies: [
				"InitMacro",
				"DewdropService"
			]
		),
		.testTarget(
			name: "RaindropTests",
			dependencies: ["Raindrop"]
		),
	]
)
