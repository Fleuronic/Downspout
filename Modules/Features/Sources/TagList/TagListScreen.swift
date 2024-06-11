// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Tag
import struct Raindrop.Collection
import struct Raindrop.Raindrop

public typealias TagList = Tag.List

public extension Tag {
	enum List {}
}

// MARK: -
public extension TagList {
	struct Screen {
		let tags: [Tag]
		let selectRaindrop: (Raindrop) -> Void
		let updateTags: () -> Void
		let isUpdatingTags: Bool
	}
}

// MARK: -
public extension TagList.Screen {
	var emptyTitle: String { "No tags" }
	var loadingTitle: String { "Loading…" }
}
