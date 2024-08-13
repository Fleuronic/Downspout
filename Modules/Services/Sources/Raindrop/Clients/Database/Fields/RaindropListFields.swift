// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import enum Dewdrop.ItemType
import struct Raindrop.Raindrop
import struct Dewdrop.Collection
import struct Foundation.URL
import struct Catena.IDFields
import protocol DewdropService.RaindropFields
import protocol Catenoid.Fields

public struct RaindropListFields {
	public let id: Raindrop.ID
	public let url: URL
	public let title: String
	public let itemType: ItemType
	public let isFavorite: Bool
	public let isBroken: Bool
	public let collection: IDFields<Collection.Identified>?
}

extension RaindropListFields: RaindropFields, Fields {
	// MARK: Fields
	public typealias Model = Raindrop.Identified

	// MARK: ModelProjection
	public static let projection = Projection<Model, Self>(
		Self.init,
		\.id,
		\.value.url,
		\.value.title,
		\.value.itemType,
		\.value.isFavorite,
		\.value.isBroken,
		\.collection.id
	)
}

// MARK: -
private extension RaindropListFields {
	init(
		id: Raindrop.ID,
		url: URL,
		title: String,
		itemType: ItemType,
		isFavorite: Bool,
		isBroken: Bool,
		collectionID: Collection.ID?
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
