// Copyright © Fleuronic LLC. All rights reserved.

import SFSafeSymbols

import enum Dewdrop.ItemType
import enum RaindropList.RaindropList
import struct Raindrop.Filter
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import struct Identity.Identifier
import class AppKit.NSImage

public typealias FilterList = Filter.List

public extension Filter {
	enum List {}
}

// MARK: -
public extension FilterList {
	struct Screen {
		public let loadRaindrops: (Filter.ID, Int) -> Void
		public let isLoadingRaindrops: (Filter.ID) -> Bool
		public let finishLoadingRaindrops: (Filter.ID) -> Void
		public let selectRaindrop: (Raindrop) -> Void

		let filters: [Filter]
		let loadFilters: () -> Void
	}
}

// MARK: -
public extension FilterList.Screen {
	func title(for filter: Filter) -> String {
		switch Filter.ID.Name(rawValue: filter.id.rawValue) {
		case .favorited: "Favorites"
		case .highlighted: "Highlights"
		case .duplicate: "Duplicates"
		case .untagged: "Without tags"
		case .broken: "Broken"
		case nil: title(for: filter.itemType!)
		}
	}

	func title(for itemType: ItemType) -> String {
		switch itemType {
		case .link: "Links"
		case .article: "Articles"
		case .document: "Documents"
		case .image: "Images"
		case .audio: "Audio"
		case .video: "Video"
		}
	}

	func icon(for filter: Filter) -> NSImage {
		switch Filter.ID.Name(rawValue: filter.id.rawValue) {
		case .favorited: heartIcon
		case .highlighted: pencilTipIcon
		case .duplicate: squaresIcon
		case .untagged: tagIcon
		case .broken: brokenLinkIcon
		case nil: icon(for: filter.itemType!)
		}
	}

	func icon(for itemType: ItemType) -> NSImage {
		switch itemType {
		case .link: linkIcon
		case .article: articleIcon
		case .document: documentIcon
		case .image: pictureIcon
		case .audio: speakerIcon
		case .video: videoIcon
		}
	}
}

// MARK: -
extension FilterList.Screen: RaindropList.Screen {
	public var emptyTitle: String { "No Filters" }
}

// MARK: -
private extension FilterList.Screen {
	var heartIcon: NSImage { .init(systemSymbol: .heart) }
	var pencilTipIcon: NSImage { .init(systemSymbol: .pencilTip) }
	var squaresIcon: NSImage { .init(systemSymbol: .squareOnSquare) }
	var tagIcon: NSImage { .init(systemSymbol: .number) }
	var brokenLinkIcon: NSImage { .init(systemSymbol: .xmarkIcloud) }
	var linkIcon: NSImage { .init(systemSymbol: .link) }
	var articleIcon: NSImage { .init(systemSymbol: .docRichtext) }
	var documentIcon: NSImage { .init(systemSymbol: .docText) }
	var pictureIcon: NSImage { .init(systemSymbol: .personCropSquare) }
	var speakerIcon: NSImage { .init(systemSymbol: .speakerWave2) }
	var videoIcon: NSImage { .init(systemSymbol: .video) }
}
