// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import enum Dewdrop.ItemType
import struct Raindrop.Raindrop
import struct Dewdrop.Collection
import struct Dewdrop.Highlight
import struct Foundation.URL
import struct Catena.IDFields
import protocol DewdropService.RaindropFields
import protocol Catenoid.Fields

struct RaindropCreationFields: RaindropFields {
	let id: Raindrop.ID
	let url: URL
	let title: String
	let itemType: ItemType

	@Sendable private init(id: Raindrop.ID, url: URL, title: String, itemType: ItemType) {
		self.id = id
		self.url = url
		self.title = title
		self.itemType = itemType
	}
}

extension RaindropCreationFields: Fields {
	// MARK: ModelProjection
	static let projection = Projection<Self.Model, Self>(
		Self.init,
		\.id,
		\.value.url,
		\.value.title,
		\.value.itemType
	)
}
