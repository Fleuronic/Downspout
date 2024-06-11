// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.Collection
import struct DewdropService.IdentifiedCollection

public struct Collection: Equatable {
	public let id: ID
	public let title: String
	public let count: Int
	public let collections: [Collection]
	public let loadedRaindrops: [Raindrop]

	public init(
		id: ID,
		title: String,
		count: Int,
		collections: [Collection],
		loadedRaindrops: [Raindrop] = []
	) {
		self.id = id
		self.title = title
		self.count = count
		self.collections = collections
		self.loadedRaindrops = loadedRaindrops
	}
}

// MARK: -
public extension Collection {
	typealias ID = Dewdrop.Collection.ID
}
