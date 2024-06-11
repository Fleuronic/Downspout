// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import class AppKit.NSImage

public typealias GroupList = Group.List

public extension Group {
	enum List {}
}

// MARK: -
public extension GroupList {
	struct Screen {
		let groups: [Group]
		let updateGroups: () -> Void
		let updateRaindrops: (Collection.ID) -> Void
		let isUpdatingGroups: Bool
		let isUpdatingRaindrops: (Collection.ID) -> Bool
		let selectRaindrop: (Raindrop) -> Void
	}
}

// MARK: -
public extension GroupList.Screen {
	var emptyTitle: String { "No bookmarks" }
	var loadingTitle: String { "Loading…" }

	func icon(for collection: Collection) -> NSImage {
		collection.isShared ? sharedIcon : folderIcon
	}

	func icon(for raindrop: Raindrop) -> NSImage {
		websiteIcon
	}
}

private extension GroupList.Screen {
	var folderIcon: NSImage { .init(systemSymbolName: "folder", accessibilityDescription: nil)! }
	var sharedIcon: NSImage { .init(systemSymbolName: "person", accessibilityDescription: nil)! }
	var websiteIcon: NSImage { .init(systemSymbolName: "globe", accessibilityDescription: nil)! }
}
