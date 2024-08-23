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
public extension Highlight {
	// MARK: Model
	var valueSet: ValueSet<Identified> {
		[
			\.raindrop == raindropID,
			\.value.content.text == .init()
		]
	}
}

// MARK: -
#if compiler(>=6.0)
extension Highlight: @retroactive Model {}
#else
extension Highlight: Model {}
#endif
