// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Collection
import protocol Catenoid.Fields
import protocol DewdropService.CollectionFields

struct SystemCollectionListFields: CollectionFields {
	let id: Collection.ID
	let title: String
	let count: Int
	let sortIndex: Int

	@Sendable private init(
		id: Collection.ID,
		title: String,
		count: Int,
		sortIndex: Int
	) {
		self.id = id
		self.title = title
		self.count = count
		self.sortIndex = sortIndex
	}
}

// MARK
extension SystemCollectionListFields: Fields {
	// MARK: ModelProjection
	public static let projection = Projection<Self.Model, Self>(
		Self.init,
		\.id,
		\.value.title,
		\.value.count,
		\.value.sortIndex
	)
}
