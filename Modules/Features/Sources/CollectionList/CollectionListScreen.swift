// Copyright © Fleuronic LLC. All rights reserved.

import enum RaindropList.RaindropList
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import class AppKit.NSImage
import struct Identity.Identifier
import struct DewdropService.IdentifiedRaindrop

public typealias CollectionList = Collection.List

public extension Collection {
	enum List {}
}

// MARK: -
public extension CollectionList {
	struct Screen {
		public let updateRaindrops: (Collection.ID, Int) -> Void
		public let isUpdatingRaindrops: (Collection.ID) -> Bool
		public let selectRaindrop: (Raindrop) -> Void

		let collections: [Collection]
		let updateCollections: () -> Void
		let isUpdatingCollections: Bool
	}
}

// MARK: -
extension CollectionList.Screen: RaindropList.Screen {
	public var emptyTitle: String { "No bookmarks" }

	public func icon(for collection: Collection) -> NSImage {
		switch collection.id {
		case .all: cloudIcon
		case .unsorted: inboxIcon
		case .trash: trashIcon
		default: folderIcon
		}
	}
}

private extension CollectionList.Screen {
	var cloudIcon: NSImage { .init(systemSymbolName: "cloud", accessibilityDescription: nil)! }
	var inboxIcon: NSImage { .init(systemSymbolName: "tray", accessibilityDescription: nil)! }
	var trashIcon: NSImage { .init(systemSymbolName: "trash", accessibilityDescription: nil)! }
	var folderIcon: NSImage { .init(systemSymbolName: "folder", accessibilityDescription: nil)! }
	var websiteIcon: NSImage { .init(systemSymbolName: "globe", accessibilityDescription: nil)! }
}
