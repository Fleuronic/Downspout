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
		associatedtype ItemKey: Hashable
		associatedtype LoadingID: Hashable

		var emptyTitle: String { get }
		var loadRaindrops: (LoadingID, Int) -> Void { get }
		var isLoadingRaindrops: (LoadingID) -> Bool { get }
		var finishLoadingRaindrops: (LoadingID) -> Void { get }
		var selectRaindrop: (Raindrop) -> Void { get }

		func icon(for collection: Collection) -> NSImage
	}
}

// MARK: -
public extension RaindropList.Screen {
	var loadingTitle: String { "Loading raindrops…" }

	var folderIcon: NSImage { .init(systemSymbol: .folder) }
	var websiteIcon: NSImage { .init(systemSymbol: .globe) }

	func icon(for collection: Collection) -> NSImage { folderIcon }
	func icon(for raindrop: Raindrop) -> NSImage { websiteIcon }
}
