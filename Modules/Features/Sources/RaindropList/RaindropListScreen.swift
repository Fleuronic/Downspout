// Copyright © Fleuronic LLC. All rights reserved.

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

	func icon(for collection: Collection) -> NSImage {
		.init(systemSymbolName: "folder", accessibilityDescription: nil)!
	}

	func icon(for raindrop: Raindrop) -> NSImage {
		.init(systemSymbolName: "globe", accessibilityDescription: nil)!
	}
}
