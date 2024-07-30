// Copyright © Fleuronic LLC. All rights reserved.

import SFSafeSymbols

import enum RaindropList.RaindropList
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import struct Identity.Identifier
import struct DewdropService.IdentifiedCollection
import class AppKit.NSImage

public typealias CollectionList = Collection.List

public extension Collection {
	enum List {}
}

// MARK: -
public extension CollectionList {
	struct Screen {
		public let loadRaindrops: (Collection.ID, Int) -> Void
		public let isLoadingRaindrops: (Collection.ID) -> Bool
		public let finishLoadingRaindrops: (Collection.ID) -> Void
		public let selectRaindrop: (Raindrop) -> Void

		let collections: [Collection]
		let loadCollections: () -> Void
	}
}

// MARK: -
extension CollectionList.Screen: RaindropList.Screen {
	public typealias ItemKey = Collection.Key
	public typealias LoadingID = Collection.ID

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

// MARK: -
private extension CollectionList.Screen {
	var cloudIcon: NSImage { .init(systemSymbol: .cloud) }
	var inboxIcon: NSImage { .init(systemSymbol: .tray) }
	var trashIcon: NSImage { .init(systemSymbol: .trash) }
}
