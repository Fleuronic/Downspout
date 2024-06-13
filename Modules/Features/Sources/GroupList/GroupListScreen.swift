// Copyright © Fleuronic LLC. All rights reserved.

import SFSafeSymbols

import enum RaindropList.RaindropList
import struct Raindrop.Group
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import class AppKit.NSImage
import struct Identity.Identifier
import struct DewdropService.IdentifiedRaindrop

public typealias GroupList = Group.List

public extension Group {
	enum List {}
}

// MARK: -
public extension GroupList {
	struct Screen {
		public let updateRaindrops: (Collection.ID, Int) -> Void
		public let isUpdatingRaindrops: (Collection.ID) -> Bool
		public let selectRaindrop: (Raindrop) -> Void

		let groups: [Group]
		let updateGroups: () -> Void
		let isUpdatingGroups: Bool
	}
}

// MARK: -
extension GroupList.Screen: RaindropList.Screen {
	public var emptyTitle: String { "No bookmarks" }

	public func icon(for collection: Collection) -> NSImage {
		collection.isShared ? sharedFolderIcon : folderIcon
	}
}

// MARK: -
private extension GroupList.Screen {
	var sharedFolderIcon: NSImage { .init(systemSymbol: .folderBadgePersonCrop) }
}
