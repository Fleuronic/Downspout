// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import struct Raindrop.Collection
import struct Raindrop.Raindrop

public typealias GroupList = Group.List

public extension Group {
	enum List {}
}

public extension GroupList {
	struct Screen {
		let name: String
		let collections: [Collection]
		let selectRaindrop: (Raindrop) -> Void
	}
}
