// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Dewdrop.Highlight
import struct DewdropService.IdentifiedHighlight
import struct Identity.Identifier

@Init public struct Highlight: Equatable, Sendable {
	public let id: ID
	public let raindropID: Raindrop.ID
}

// MARK: -
public extension Highlight {
	typealias ID = Identified.ID
	typealias Identified = Dewdrop.Highlight.Identified
}
