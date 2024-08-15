// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import enum Dewdrop.ItemType
import struct Foundation.URL
import struct Dewdrop.Raindrop
import struct DewdropService.IdentifiedRaindrop
import struct Identity.Identifier

@Init public struct Raindrop: Equatable, Sendable {
	public let id: ID
	public let collectionID: Collection.ID?
	public let url: URL
	public let title: String
	public let itemType: ItemType
	public let isFavorite: Bool
	public let isBroken: Bool
	public let highlights: [Highlight]?
}

// MARK: -
public extension Raindrop {
	typealias ID = Identified.ID
	typealias Identified = Dewdrop.Raindrop.Identified
}
