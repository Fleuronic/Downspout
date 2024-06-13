// Copyright © Fleuronic LLC. All rights reserved.

import SFSafeSymbols

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import class AppKit.NSImage

public typealias RaindropList = Raindrop.List

public extension Raindrop {
	enum List {}
}

// MARK: -
public extension RaindropList {
	protocol Screen {
		associatedtype ItemID: Hashable

		var emptyTitle: String { get }
		var updateRaindrops: (ItemID, Int) -> Void { get }
		var isUpdatingRaindrops: (ItemID) -> Bool { get }
		var selectRaindrop: (Raindrop) -> Void { get }

		func icon(for collection: Collection) -> NSImage
	}
}

// MARK: -
public extension RaindropList.Screen {
	var loadingTitle: String { "Loading…" }

	var folderIcon: NSImage { .init(systemSymbol: .folder) }
	var websiteIcon: NSImage { .init(systemSymbol: .globe) }

	func icon(for collection: Collection) -> NSImage { folderIcon }
	func icon(for raindrop: Raindrop) -> NSImage { websiteIcon }
}
