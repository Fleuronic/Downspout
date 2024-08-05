// Copyright © Fleuronic LLC. All rights reserved.

import enum RaindropList.RaindropList
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import struct Identity.Identifier
import struct DewdropService.IdentifiedCollection
import class SafeSFSymbols.SafeSFSymbol

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

	public func icon(for collection: Collection) -> SafeSFSymbol {
		switch collection.id {
		case .all: .cloud
		case .unsorted: .tray
		case .trash: .trash
		default: folderIcon
		}
	}
}

// MARK: -
private extension CollectionList.Screen {
	var cloudIcon: SafeSFSymbol { .cloud }
	var inboxIcon: SafeSFSymbol { .tray }
	var trashIcon: SafeSFSymbol { .trash }
}
