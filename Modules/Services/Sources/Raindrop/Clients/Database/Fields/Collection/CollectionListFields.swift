// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Collection
import struct Dewdrop.Group
import struct Catena.IDFields
import protocol Catenoid.Fields
import protocol DewdropService.CollectionFields

struct CollectionListFields: CollectionFields {
	let id: Collection.ID
	let parentID: Collection.ID?
	let title: String
	let count: Int
	let isShared: Bool
	let sortIndex: Int
	let group: IDFields<Group.Identified>
}

// MARK
extension CollectionListFields: Fields {
	// MARK: ModelProjection
	static let projection = Projection<Self.Model, Self>(
		Self.init,
		\.id,
		\.parentID,
		\.value.title,
		\.value.count,
		\.value.isShared,
		\.value.sortIndex,
		\.group.id
	)
}

// MARK: -
private extension CollectionListFields {
	@Sendable private init(
		id: Collection.ID,
		parentID: Collection.ID?,
		title: String,
		count: Int,
		isShared: Bool,
		sortIndex: Int,
		groupID: Group.ID
	) {
		self.id = id
		self.parentID = parentID
		self.title = title
		self.count = count
		self.isShared = isShared
		self.sortIndex = sortIndex

		group = .init(id: groupID)
	}
}
