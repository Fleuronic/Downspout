// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.Collection
import struct DewdropService.IdentifiedCollection
import struct Identity.Identifier

public struct Collection: Equatable, Sendable {
	public let id: ID
	public let title: String
	public let count: Int
	public let isShared: Bool
	public let groupID: Group.ID?
	public let parentID: ID? // TODO: Move
	public let collections: [Collection]
	public let raindrops: [Raindrop]?

	public init(
		id: ID,
		title: String,
		count: Int,
		isShared: Bool,
		groupID: Group.ID?,
		parentID: ID?,
		collections: [Collection],
		raindrops: [Raindrop]?
	) {
		self.id = id
		self.title = title
		self.count = count
		self.isShared = isShared
		self.groupID = groupID
		self.parentID = parentID
		self.collections = collections
		self.raindrops = raindrops
	}
}

// MARK: -
public extension Collection {
	typealias ID = Identified.ID
	typealias Identified = Dewdrop.Collection.Identified

	init?(
		id: ID,
		count: Int,
		groupID: Group.ID?,
		parentID: ID?
	) {
		switch (id, count) {
		case (.all, _):
			title = "All bookmarks"
		case (.unsorted, _):
			title = "Unsorted"
		case let (.trash, count) where count > 0:
			title = "Trash"
		default:
			return nil
		}

		self.id = id
		self.count = count
		self.groupID = groupID
		self.parentID = parentID

		isShared = false
		collections = []
		raindrops = nil
	}
}

// MARK: -
public extension [Collection] {
	func updated(with raindrops: [Raindrop], for id: Collection.ID) -> [Collection] {
		map { collection in
			.init(
				id: collection.id,
				title: collection.title,
				count: collection.count,
				isShared: collection.isShared,
				groupID: collection.groupID,
				parentID: collection.parentID,
				collections: collection.collections.updated(with: raindrops, for: id),
				raindrops: collection.id == id ? raindrops : collection.raindrops
			)
		}
	}
}
