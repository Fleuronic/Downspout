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

public struct RaindropListFields: RaindropFields {
	public let id: Raindrop.ID
	public let url: URL
	public let title: String
	public let itemType: ItemType
	public let isFavorite: Bool
	public let isBroken: Bool
	public let collection: IDFields<Collection.Identified>?
}

extension RaindropListFields: Fields {
	// MARK: ModelProjection
	public static let projection = Projection<Self.Model, Self>(
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
	init(
		id: Raindrop.ID,
		collectionID: Collection.ID?,
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

		collection = collectionID.map(IDFields.init)
	}
}
