// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

@Init public struct Collection: Equatable {
	public let name: String
	public let collections: [Collection]
	public let raindrops: [Raindrop]
}
