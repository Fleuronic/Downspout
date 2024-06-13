// Copyright © Fleuronic LLC. All rights reserved.

import enum RaindropList.RaindropList
import struct Raindrop.Filter
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import class AppKit.NSImage

public typealias FilterList = Filter.List

public extension Filter {
	enum List {}
}

// MARK: -
public extension FilterList {
	struct Screen {
		public let updateRaindrops: (Filter.ID, Int) -> Void
		public let isUpdatingRaindrops: (Filter.ID) -> Bool
		public let selectRaindrop: (Raindrop) -> Void

		let filters: [Filter]
		let updateFilters: () -> Void
		let isUpdatingFilters: Bool
	}
}

// MARK: -
extension FilterList.Screen: RaindropList.Screen {
	public var emptyTitle: String { "No Filters" }
}
