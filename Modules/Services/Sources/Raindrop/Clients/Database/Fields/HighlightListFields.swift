// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Highlight
import struct Dewdrop.Raindrop
import protocol Catenoid.Fields
import protocol DewdropService.HighlightFields

struct HighlightListFields: HighlightFields {
	let id: Highlight.ID
	let raindropID: Raindrop.ID

	@Sendable private init(
		id: Highlight.ID,
		raindropID: Raindrop.ID
	) {
		self.id = id
		self.raindropID = raindropID
	}
}

// MARK
extension HighlightListFields: Fields {
	// MARK: ModelProjection
	static let projection = Projection<Self.Model, Self>(
		Self.init,
		\.id,
		\.raindrop.id
	)
}
