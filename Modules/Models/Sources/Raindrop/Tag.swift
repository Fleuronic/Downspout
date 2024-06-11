// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

@Init public struct Tag: Equatable {
	public let name: String
	public let raindropCount: Int
	public let loadedRaindrops: [Raindrop]
}
