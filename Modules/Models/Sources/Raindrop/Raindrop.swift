// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Foundation.URL
import struct Dewdrop.Raindrop
import struct DewdropService.IdentifiedRaindrop
import protocol Identity.Identifiable

@Init public struct Raindrop: Equatable, Sendable {
	public let id: ID
	public let collectionID: Collection.ID?
	public let title: String
	public let url: URL
}

// MARK: -
public extension Raindrop {
	typealias ID = Dewdrop.Raindrop.ID
	typealias Identified = Dewdrop.Raindrop.Identified
}
