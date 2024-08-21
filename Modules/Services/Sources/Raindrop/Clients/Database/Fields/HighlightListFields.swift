// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Highlight
import struct Dewdrop.Raindrop
import protocol Catenoid.Fields
import protocol DewdropService.HighlightFields

public struct HighlightListFields: HighlightFields {
	public let id: Highlight.ID
	public let raindropID: Raindrop.ID
}

// MARK
extension HighlightListFields: Fields {
	// MARK: ModelProjection
	public static let projection = Projection<Self.Model, Self>(
		Self.init,
		\.id,
		\.raindrop.id
	)
}
