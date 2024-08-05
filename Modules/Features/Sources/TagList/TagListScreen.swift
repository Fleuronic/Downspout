// Copyright © Fleuronic LLC. All rights reserved.

import enum RaindropList.RaindropList
import struct Raindrop.Tag
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import class SafeSFSymbols.SafeSFSymbol

public typealias TagList = Tag.List

public extension Tag {
	enum List {}
}

// MARK: -
public extension TagList {
	struct Screen {
		public let loadRaindrops: (String, Int) -> Void
		public let isLoadingRaindrops: (String) -> Bool
		public let finishLoadingRaindrops: (String) -> Void
		public let selectRaindrop: (Raindrop) -> Void

		let tags: [Tag]
		let loadTags: () -> Void
	}
}

// MARK: -
extension TagList.Screen {
	var tagsTitle: String { "Tags (\(tags.count))" }
	var tagIcon: SafeSFSymbol { .number }
}

// MARK: -
extension TagList.Screen: RaindropList.Screen {
	public typealias ItemKey = Tag.Key
	public typealias LoadingID = Tag.ID

	public var emptyTitle: String { "No tags" }
}
