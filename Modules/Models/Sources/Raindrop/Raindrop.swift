// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Foundation.URL
import struct Dewdrop.Raindrop
import struct DewdropService.IdentifiedRaindrop

@Init public struct Raindrop: Equatable {
	public let id: ID
	public let collectionID: Collection.ID?
	public let title: String
	public let url: URL
}

// MARK: -
public extension Raindrop {
	typealias ID = Dewdrop.Raindrop.ID
}
