// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import struct Raindrop.Raindrop
import class AppKit.NSImage

public typealias CollectionList = Collection.List

public extension Collection {
	enum List {}
}

// MARK: -
public extension CollectionList {
	struct Screen {
		let collections: [Collection]
		let updateCollections: () -> Void
		let updateRaindrops: (Collection.ID, Int) -> Void
		let isUpdatingCollections: Bool
		let isUpdatingRaindrops: (Collection.ID) -> Bool
		let selectRaindrop: (Raindrop) -> Void
	}
}

// MARK: -
public extension CollectionList.Screen {
	var emptyTitle: String { "No bookmarks" }
	var loadingTitle: String { "Loading…" }

	func icon(for collection: Collection) -> NSImage { 
		switch collection.id {
		case .all: cloudIcon
		case .unsorted: inboxIcon
		case .trash: trashIcon
		default: folderIcon
		}
	}

	func icon(for raindrop: Raindrop) -> NSImage { websiteIcon }
}

private extension CollectionList.Screen {
	var cloudIcon: NSImage { .init(systemSymbolName: "cloud", accessibilityDescription: nil)! }
	var inboxIcon: NSImage { .init(systemSymbolName: "tray", accessibilityDescription: nil)! }
	var trashIcon: NSImage { .init(systemSymbolName: "trash", accessibilityDescription: nil)! }
	var folderIcon: NSImage { .init(systemSymbolName: "folder", accessibilityDescription: nil)! }
	var websiteIcon: NSImage { .init(systemSymbolName: "globe", accessibilityDescription: nil)! }
}
