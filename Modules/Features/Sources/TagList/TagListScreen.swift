// Copyright © Fleuronic LLC. All rights reserved.

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
		let tags: [Tag]
		let updateTags: () -> Void
		let updateRaindrops: (String) -> Void
		let isUpdatingTags: Bool
		let isUpdatingRaindrops: (String) -> Bool
		let selectRaindrop: (Raindrop) -> Void
	}
}

// MARK: -
public extension TagList.Screen {
	var tagsTitle: String { "Tags" }
	var emptyTitle: String { "No tags" }
	var loadingTitle: String { "Loading…" }
	var websiteIcon: NSImage { .init(systemSymbolName: "globe", accessibilityDescription: nil)! }
}
