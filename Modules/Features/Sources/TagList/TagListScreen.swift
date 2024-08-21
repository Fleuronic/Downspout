// Copyright © Fleuronic LLC. All rights reserved.

import enum RaindropList.RaindropList
import struct Raindrop.Tag
import struct Raindrop.Raindrop
import struct Identity.Identifier
import struct DewdropService.IdentifiedTag
import class SafeSFSymbols.SafeSFSymbol

public typealias TagList = Tag.List

public extension Tag {
	enum List {}
}

// MARK: -
public extension TagList {
	struct Screen {
		public let loadRaindrops: (Tag.ID, Int) -> Void
		public let isLoadingRaindrops: (Tag.ID) -> Bool
		public let finishLoadingRaindrops: (Tag.ID) -> Void
		public let selectRaindrop: (Raindrop) -> Void

		let tags: [Tag]
		let loadTags: () -> Void
		let isLoadingTags: Bool
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

	public var loadingTitle: String { "Loading tags…" }
}
