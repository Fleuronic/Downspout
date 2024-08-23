// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Collection
import struct Catena.IDFields
import protocol Catenoid.Fields
import protocol DewdropService.CollectionFields

struct ChildCollectionListFields: CollectionFields {
	let id: Collection.ID
	let parentID: Collection.ID
	let title: String
	let count: Int
	let isShared: Bool
	let sortIndex: Int
}

// MARK
extension ChildCollectionListFields: Fields {
	// MARK: ModelProjection
	static let projection = Projection<Self.Model, Self>(
		Self.init,
		\.id,
		\.parentID,
		\.value.title,
		\.value.count,
		\.value.isShared,
		\.value.sortIndex
	)
}

// MARK: -
private extension ChildCollectionListFields {
	@Sendable private init(
		id: Collection.ID,
		parentID: Collection.ID?,
		title: String,
		count: Int,
		isShared: Bool,
		sortIndex: Int
	) {
		self.id = id
		self.parentID = parentID!
		self.title = title
		self.count = count
		self.isShared = isShared
		self.sortIndex = sortIndex
	}
}
