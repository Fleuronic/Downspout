// Copyright © Fleuronic LLC. All rights reserved.

import enum Dewdrop.ItemType
import struct Dewdrop.Filter
import struct Dewdrop.Raindrop
import struct DewdropService.Identified
import protocol Identity.Identifiable

public struct Filter: Equatable, Sendable {
	public let id: ID
	public let count: Int
	public let loadedRaindrops: [Raindrop]

	public init(
		id: ID,
		count: Int,
		loadedRaindrops: [Raindrop] = []
	) {
		self.id = id
		self.count = count
		self.loadedRaindrops = loadedRaindrops
	}
}

// MARK: -
public extension Filter {
	typealias ID = Dewdrop.Filter.ID

	var itemType: ItemType? {
		.init(rawValue: id.rawValue)
	}
}

public extension Filter.ID {
	enum Name: String {
		case favorited = "❤️"
		case highlighted = "highlights"
		case duplicate = "duplicate"
		case untagged = "notag"
		case broken
	}

	init(_ name: Name) {
		self.init(rawValue: name.rawValue)
	}
}
