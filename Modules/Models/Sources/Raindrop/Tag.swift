// Copyright © Fleuronic LLC. All rights reserved.

public struct Tag: Equatable, Sendable {
	public let name: String
	public let raindropCount: Int
	public let loadedRaindrops: [Raindrop]
	
	public init(
		name: String,
		raindropCount: Int,
		loadedRaindrops: [Raindrop] = []
	) {
		self.name = name
		self.raindropCount = raindropCount
		self.loadedRaindrops = loadedRaindrops
	}
}
