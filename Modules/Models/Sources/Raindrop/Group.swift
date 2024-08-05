// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Dewdrop.Group
import struct DewdropService.IdentifiedGroup
import struct Identity.Identifier

@Init public struct Group: Equatable, Sendable {
	public let title: String
	public let sortIndex: Int
	public let collections: [Collection]
}

// MARK: -
public extension Group {
	typealias ID = Identified.ID
	typealias Identified = Dewdrop.Group.Identified

	struct Key: Hashable {
		fileprivate let rawValue: String
	}

	var id: ID { .init(rawValue: title) }
	var key: Key { .init(rawValue: title) }
}
