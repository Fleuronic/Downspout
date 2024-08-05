// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import class SafeSFSymbols.SafeSFSymbol

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

		func icon(for collection: Collection) -> SafeSFSymbol
	}
}

// MARK: -
public extension RaindropList.Screen {
	var loadingTitle: String { "Loading raindrops…" }

	var folderIcon: SafeSFSymbol { .folder }
	var websiteIcon: SafeSFSymbol { .globe }

	func icon(for collection: Collection) -> SafeSFSymbol { folderIcon }
	func icon(for raindrop: Raindrop) -> SafeSFSymbol { websiteIcon }
}
