// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Group
import struct Dewdrop.Collection
import struct Catena.IDFields
import protocol Catenoid.Fields
import protocol DewdropService.GroupFields

struct GroupListFields: GroupFields {
	let title: String
	let sortIndex: Int
	let collections: [CollectionListFields]
}

// MARK
extension GroupListFields: Fields {
	// MARK: ModelProjection
	var id: Group.ID { .init(rawValue: title) }

	// MARK: ModelProjection
	static let projection = Projection<Self.Model, Self>(
		Self.init,
		\.id,
		\.value.sortIndex,
		\.collections.id,
		\.collections.value.title,
		\.collections.value.count,
		\.collections.value.isShared,
		\.collections.value.sortIndex
	)

	// MARK: Fields
	static func merge(lhs: Self, rhs: Self) -> Self {
		let id = lhs.id
		let sortIndex = lhs.sortIndex
		let lhs = lhs.collections
		let rhs = rhs.collections

		return .init(
			id: id,
			sortIndex: sortIndex,
			collectionIDs: lhs.map(\.id) + rhs.map(\.id),
			collectionTitles: lhs.map(\.title) + rhs.map(\.title),
			collectionCounts: lhs.map(\.count) + rhs.map(\.count),
			collectionIsSharedFlags: lhs.map(\.isShared) + rhs.map(\.isShared),
			collectionSortIndices: lhs.map(\.sortIndex) + rhs.map(\.sortIndex)
		)
	}
}

// MARK: -
private extension GroupListFields {
	@Sendable private init(
		id: Group.ID,
		sortIndex: Int,
		collectionIDs: [Collection.ID],
		collectionTitles: [String],
		collectionCounts: [Int],
		collectionIsSharedFlags: [Bool],
		collectionSortIndices: [Int]
	) {
		self.sortIndex = sortIndex

		let groupID = id
		title = id.rawValue
		collections = collectionIDs.enumerated().map { index, id in
			.init(
				id: id,
				parentID: nil,
				title: collectionTitles[index],
				count: collectionCounts[index],
				isShared: collectionIsSharedFlags[index],
				sortIndex: collectionSortIndices[index],
				group: .init(id: groupID)
			)
		}
	}
}
