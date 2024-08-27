// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Dewdrop.User
import struct DewdropService.IdentifiedUser
import struct Identity.Identifier

@Init public struct User: Equatable, Sendable {
	public let id: ID
	public let fullName: String
}

// MARK: -
public extension User {
	typealias ID = Identified.ID
	typealias Identified = Dewdrop.User.Identified
}
