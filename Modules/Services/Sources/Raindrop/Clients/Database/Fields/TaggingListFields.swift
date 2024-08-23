// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Tag
import struct Dewdrop.Raindrop
import struct Catena.IDFields
import struct DewdropService.Tagging
import protocol DewdropService.TagFields
import protocol Catenoid.Fields

struct TaggingListFields {
	let id: Tagging.ID
	let raindropID: Raindrop.ID
	let tagName: String

	@Sendable private init(
		id: Tagging.ID,
		raindropID: Raindrop.ID,
		tagName: String
	) {
		self.id = id
		self.raindropID = raindropID
		self.tagName = tagName
	}
}

// MARK
extension TaggingListFields: Fields {
	// MARK: ModelProjection
	static let projection = Projection<Tagging, Self>(
		Self.init,
		\.id,
		\.raindrop.id,
		\.tagName
	)
}
