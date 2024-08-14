// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Collection
import struct Dewdrop.Group
import struct Catena.IDFields
import protocol Catenoid.Fields
import protocol DewdropService.CollectionFields

public struct CollectionListFields: CollectionFields {
	public let id: Collection.ID
	public let parentID: Collection.ID?
	public let title: String
	public let count: Int
	public let isShared: Bool
	public let sortIndex: Int
	public let group: IDFields<Group.Identified>?
}

// MARK
extension CollectionListFields: Fields {
	// MARK: Fields
	public typealias Model = Collection.Identified

	// MARK: Fields
	public static func merge(lhs: Self, rhs: Self) -> Self { lhs }

	// MARK: ModelProjection
	public static let projection = Projection<Model, Self>(
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
	init(
		id: Collection.ID,
		parentID: Collection.ID?,
		title: String,
		count: Int,
		isShared: Bool,
		sortIndex: Int,
		groupID: Group.ID?
	) {
		self.id = id
		self.parentID = parentID
		self.title = title
		self.count = count
		self.isShared = isShared
		self.sortIndex = sortIndex

		group = groupID.map(IDFields.init)
	}
}
