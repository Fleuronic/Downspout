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
	dependencies: [.package(path: "../../../Dewdrop/Submodules/DewdropService")],
	targets: [
		.target(
			name: "Raindrop",
			dependencies: ["DewdropService"]
		),
		.testTarget(
			name: "RaindropTests",
			dependencies: ["Raindrop"]
		),
	],
	swiftLanguageModes: [.v6]
)
