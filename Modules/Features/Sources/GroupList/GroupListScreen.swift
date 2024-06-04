// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import struct Raindrop.Collection
import struct Raindrop.Raindrop

public typealias GroupList = Group.List

public extension Group {
	enum List {}
}

// MARK: -
public extension GroupList {
	struct Screen {
		let groups: [Group]
		let selectRaindrop: (Raindrop) -> Void
		let updateGroups: () -> Void
		let isUpdatingGroups: Bool
	}
}

// MARK: -
public extension GroupList.Screen {
	var emptyTitle: String { "No bookmarks" }
	var loadingTitle: String { "Loading…" }
}
