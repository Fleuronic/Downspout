// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Highlight
import struct Raindrop.Raindrop

extension Highlight {
	init(
		fields: HighlightListFields,
		raindropID: Raindrop.ID
	) {
		self.init(
			id: fields.id,
			raindropID: raindropID
		)
	}
}
