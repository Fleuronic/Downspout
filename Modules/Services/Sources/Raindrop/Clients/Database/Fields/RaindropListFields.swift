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

struct RaindropListFields: RaindropFields {
	let id: Raindrop.ID
	let url: URL
	let title: String
	let itemType: ItemType
	let isFavorite: Bool
	let isBroken: Bool
	let collection: IDFields<Collection.Identified>
}

extension RaindropListFields: Fields {
	// MARK: ModelProjection
	static let projection = Projection<Self.Model, Self>(
		Self.init,
		\.id,
		\.collection.id,
		\.value.url,
		\.value.title,
		\.value.itemType,
		\.value.isFavorite,
		\.value.isBroken
	)
}

// MARK: -
private extension RaindropListFields {
	@Sendable private init(
		id: Raindrop.ID,
		collectionID: Collection.ID,
		url: URL,
		title: String,
		itemType: ItemType,
		isFavorite: Bool,
		isBroken: Bool
	) {
		self.id = id
		self.title = title
		self.url = url
		self.itemType = itemType
		self.isFavorite = isFavorite
		self.isBroken = isBroken

		collection = .init(id: collectionID)
	}
}
