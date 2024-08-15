// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB
import DewdropDatabase

import struct Raindrop.Highlight
import struct DewdropService.IdentifiedHighlight
import protocol Catenoid.Model

extension Highlight {
	init(fields: HighlightListFields) {
		self.init(
			id: fields.id,
			raindropID: fields.raindropID
		)
	}
}

// MARK: -
extension Highlight: @retroactive Model {
	// MARK: Model
	public var valueSet: ValueSet<Identified> {
		[
			\.raindrop == raindropID,
			\.value.content.text == .init()
		]
	}
}
