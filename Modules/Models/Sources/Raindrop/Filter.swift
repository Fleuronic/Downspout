// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import enum Dewdrop.ItemType
import struct Dewdrop.Filter
import struct Dewdrop.Raindrop
import struct DewdropService.IdentifiedFilter
import struct Identity.Identifier

@Init public struct Filter: Equatable, Sendable {
	public let id: ID
	public let count: Int
	public let sortIndex: Int

	public var raindrops: [Raindrop]?
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
		switch Filter.ID.Name(id: id) {
		case .favorited: Filter.ID.Name.favorited.rawValue
		case let name?: "\(name.rawValue):true"
		case nil: "type:\(id.rawValue)"
		}
	}

	static func itemType(forQuery query: String) -> ItemType? {
		guard query.hasPrefix("type:") else { return nil }

		let typeName = query.components(separatedBy: ":").last!
		return .init(rawValue: typeName)
	}
}
