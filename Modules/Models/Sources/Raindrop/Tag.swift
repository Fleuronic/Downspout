// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Dewdrop.Tag
import struct DewdropService.IdentifiedTag
import struct Identity.Identifier

@Init public struct Tag: Equatable, Sendable {
	public let name: String
	public let count: Int

	public var raindrops: [Raindrop]?
}

public extension Tag {
	typealias ID = Identified.ID
	typealias Identified = Dewdrop.Tag.Identified

	struct Key: Hashable {
		fileprivate let rawValue: String
	}

	var id: ID { .init(rawValue: name) }

	var key: Key {
		.init(rawValue: "\(name)-\(count)")
	}
}
