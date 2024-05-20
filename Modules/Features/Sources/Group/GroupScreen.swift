// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import struct Raindrop.Collection
import struct Raindrop.Raindrop

public extension Group {
	struct Screen {
		let name: String
		let collections: [Collection]
		let selectRaindrop: (Raindrop) -> Void
	}
}
