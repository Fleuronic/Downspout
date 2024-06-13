// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Dewdrop.Filter
import struct DewdropService.IdentifiedFilter

@Init public struct Filter: Equatable {
	public let id: ID
	public let title: String
	public let count: Int
}

// MARK: -
public extension Filter {
	typealias ID = Dewdrop.Filter.ID
}
