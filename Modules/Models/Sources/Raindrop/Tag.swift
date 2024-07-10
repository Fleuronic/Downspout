// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

@Init public struct Tag: Equatable, Sendable {
	public let name: String
	public let raindropCount: Int
	public let raindrops: [Raindrop]?
}
