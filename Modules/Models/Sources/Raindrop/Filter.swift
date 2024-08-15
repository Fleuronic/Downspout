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
}
