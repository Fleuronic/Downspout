// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Tag
import struct Dewdrop.Raindrop
import struct Catena.IDFields
import struct DewdropService.Tagging
import protocol DewdropService.TagFields
import protocol Catenoid.Fields

public struct TaggingListFields {
	public let id: Tagging.ID
	public let raindropID: Raindrop.ID
	public let tagName: String
}

// MARK
extension TaggingListFields: Fields {
	// MARK: ModelProjection
	public static let projection = Projection<Tagging, Self>(
		Self.init,
		\.id,
		\.raindrop.id,
		\.tagName
	)
}
