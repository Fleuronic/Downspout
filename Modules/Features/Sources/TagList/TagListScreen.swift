// Copyright © Fleuronic LLC. All rights reserved.

import enum RaindropList.RaindropList
import struct Raindrop.Tag
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import class AppKit.NSImage

public typealias TagList = Tag.List

public extension Tag {
	enum List {}
}

// MARK: -
public extension TagList {
	struct Screen {
		public let updateRaindrops: (String, Int) -> Void
		public let isUpdatingRaindrops: (String) -> Bool
		public let selectRaindrop: (Raindrop) -> Void

		let tags: [Tag]
		let updateTags: () -> Void
		let isUpdatingTags: Bool
	}
}

// MARK: -
extension TagList.Screen: RaindropList.Screen {
	public var emptyTitle: String { "No tags" }
}

extension TagList.Screen {
	var tagsTitle: String { "Tags (\(tags.count))" }
}
