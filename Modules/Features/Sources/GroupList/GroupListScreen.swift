// Copyright © Fleuronic LLC. All rights reserved.

import SFSafeSymbols

import enum RaindropList.RaindropList
import struct Raindrop.Group
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import struct Identity.Identifier
import struct DewdropService.IdentifiedCollection
import class AppKit.NSImage

public typealias GroupList = Group.List

public extension Group {
	enum List {}
}

// MARK: -
public extension GroupList {
	struct Screen {
		public let loadRaindrops: (Collection.ID, Int) -> Void
		public let isLoadingRaindrops: (Collection.ID) -> Bool
		public let finishLoadingRaindrops: (Collection.ID) -> Void
		public let selectRaindrop: (Raindrop) -> Void

		let groups: [Group]
		let loadGroups: () -> Void
	}
}

// MARK: -
extension GroupList.Screen: RaindropList.Screen {
	public typealias ItemKey = Collection.Key
	public typealias LoadingID = Collection.ID

	public var emptyTitle: String { "No bookmarks" }

	public func icon(for collection: Collection) -> NSImage {
		collection.isShared ? sharedFolderIcon : folderIcon
	}
}

// MARK: -
private extension GroupList.Screen {
	var sharedFolderIcon: NSImage { .init(systemSymbol: .folderBadgePersonCrop) }
}
