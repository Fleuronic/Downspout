// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

@Init public struct Group: Equatable, Sendable {
	public let title: String
	public let collections: [Collection]
}
