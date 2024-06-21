// swift-tools-version:6.0
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
		.package(path: "../../../Dewdrop/Submodules/DewdropService"),
		.package(url: "https://github.com/Fleuronic/InitMacro.git", branch: "update-swift-syntax")
	],
	targets: [
		.target(
			name: "Raindrop",
			dependencies: [
				"DewdropService",
				"InitMacro"
			]
		),
		.testTarget(
			name: "RaindropTests",
			dependencies: ["Raindrop"]
		),
	],
	swiftLanguageVersions: [.v6]
)
