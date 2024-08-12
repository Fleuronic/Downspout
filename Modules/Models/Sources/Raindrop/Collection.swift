// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Dewdrop.Collection
import struct DewdropService.IdentifiedCollection
import struct Identity.Identifier

@Init public struct Collection: Equatable, Sendable {
	public let id: ID
	public let parentID: ID?
	public let title: String
	public let count: Int
	public let isShared: Bool
	public let sortIndex: Int
	public let groupID: Group.ID?
	public let collections: [Collection]
	public let raindrops: [Raindrop]?
}

// MARK: -
public extension Collection {
	typealias ID = Identified.ID
	typealias Identified = Dewdrop.Collection.Identified

	struct Key: Hashable {
		fileprivate let rawValue: String
	}

	init?(
		id: ID,
		count: Int,
		groupID: Group.ID?,
		parentID: ID?
	) {
		switch (id, count) {
		case (.all, _):
			title = "All bookmarks"
			sortIndex = 0
		case (.unsorted, _):
			title = "Unsorted"
			sortIndex = 1
		case let (.trash, count) where count > 0:
			title = "Trash"
			sortIndex = 2
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

	var key: Key {
		.init(rawValue: "\(id)-\(count)")
	}
}

// MARK: -
public extension [Collection] {
	func updated(with raindrops: [Raindrop], for id: Collection.ID) -> [Collection] {
		map { collection in
			.init(
				id: collection.id,
				parentID: collection.parentID,
				title: collection.title,
				count: collection.count,
				isShared: collection.isShared,
				sortIndex: collection.sortIndex,
				groupID: collection.groupID,
				collections: collection.collections.updated(with: raindrops, for: id),
				raindrops: collection.id == id ? raindrops : collection.raindrops
			)
		}
	}
}
