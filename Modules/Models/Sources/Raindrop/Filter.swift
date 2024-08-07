// Copyright © Fleuronic LLC. All rights reserved.

import enum Dewdrop.ItemType
import struct Dewdrop.Filter
import struct Dewdrop.Raindrop
import struct DewdropService.IdentifiedFilter
import struct Identity.Identifier

public struct Filter: Equatable, Sendable {
	public let id: ID
	public let count: Int
	public let raindrops: [Raindrop]?

	public init(
		id: ID,
		count: Int,
		raindrops: [Raindrop]?
	) {
		self.id = id
		self.count = count
		self.raindrops = raindrops
	}
}

// MARK: -
public extension Filter {
	typealias ID = Identified.ID
	typealias Identified = Dewdrop.Filter.Identified

	struct Key: Hashable {
		fileprivate let rawValue: String
	}

	var key: Key {
		.init(rawValue: "\(id)-\(count)")
	}

	var itemType: ItemType? {
		.init(rawValue: id.rawValue)
	}

	static func query(for id: ID) -> String {
		switch Filter.ID.Name(rawValue: id.rawValue) {
		case .favorited: Filter.ID.Name.favorited.rawValue
		case let name?: "\(name.rawValue):true"
		case nil: "type:\(id.rawValue)"
		}
	}

	static func itemType(forQuery query: String) -> ItemType? {
		nil
	}
}

// MARK: -
public extension Identifier<Filter.Identified> {
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
