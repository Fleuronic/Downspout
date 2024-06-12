// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.Collection
import struct DewdropService.IdentifiedCollection

public struct Collection: Equatable {
	public let id: ID
	public let title: String
	public let count: Int
	public let isShared: Bool
	public let collections: [Collection]
	public let loadedRaindrops: [Raindrop]

	public init(
		id: ID,
		title: String,
		count: Int,
		isShared: Bool,
		collections: [Collection],
		loadedRaindrops: [Raindrop] = []
	) {
		self.id = id
		self.title = title
		self.count = count
		self.isShared = isShared
		self.collections = collections
		self.loadedRaindrops = loadedRaindrops
	}
}

// MARK: -
public extension Collection {
	typealias ID = Dewdrop.Collection.ID

	init?(
		id: ID,
		count: Int
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

		isShared = false
		collections = []
		loadedRaindrops = []
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
				collections: collection.collections.updated(with: raindrops, for: id),
				loadedRaindrops: collection.id == id ? raindrops : collection.loadedRaindrops
			)
		}
	}
}
