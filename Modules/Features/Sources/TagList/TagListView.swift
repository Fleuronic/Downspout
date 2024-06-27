// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import ErgoAppKit

import struct Raindrop.Raindrop
import struct Raindrop.Tag
import enum RaindropList.RaindropList

public extension TagList {
	final class View: NSObject {
		public var emptyItems: [String: NSMenuItem] = [:]
		public var loadingItems: [String: NSMenuItem] = [:]

		private let loadingItem: NSMenuItem
		private let loadTags: () -> Void
		private let loadRaindrops: (String, Int) -> Void
		private let finishLoadingRaindrops: (String) -> Void
		private let selectRaindrop: (Raindrop) -> Void

		private var tagsItem: NSMenuItem?
		private var tagItems: [String: NSMenuItem] = [:]
		private var tagRaindropItems: [String: [Raindrop.ID: NSMenuItem]] = [:]

		public init(screen: Screen) {			
			loadingItem = .init()
			loadingItem.title = screen.loadingTitle
			loadingItem.isEnabled = false
			
			loadTags = screen.loadTags
			loadRaindrops = screen.loadRaindrops
			finishLoadingRaindrops = screen.finishLoadingRaindrops
			selectRaindrop = screen.selectRaindrop
		}
	}
}

// MARK: -
extension TagList.View: NSMenuDelegate {
	// MARK: NSMenuDelegate
	public func menuWillOpen(_ menu: NSMenu) {
		let item = menu.supermenu?.items.first { menu === $0.submenu }
		
		if let tag = item?.representedObject as? Tag {
			loadRaindrops(tag.name, tag.raindropCount)
		} else {
			loadTags()
		}
	}

	public func menuDidClose(_ menu: NSMenu) {
		let item = menu.supermenu?.items.first { menu === $0.submenu }

		if let tag = item?.representedObject as? Tag {
			finishLoadingRaindrops(tag.name)
		}
	}
}

extension TagList.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = TagList.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		if screen.tags.isEmpty {
			return [loadingItem]
		} else {
			let tagsItem = tagsItem(with: screen)
			tagsItem.submenu?.update(with:
				screen.tags.map { tag in
					tagItem(for: tag, with: screen)
				}
			)
			return [tagsItem]
		}
	}
}

extension TagList.View: RaindropList.View {
	public var raindropAction: Selector {
		#selector(raindropItemSelected)
	}
}

// MARK: -
private extension TagList.View {
	func tagsItem(with screen: Screen) -> NSMenuItem {
		let item = tagsItem ?? makeTagsItem(with: screen)
		item.title = screen.tagsTitle
		return item
	}

	func tagItem(for tag: Tag, with screen: Screen) -> NSMenuItem {
		let item = tagItems[tag.name] ?? makeMenuItem(for: tag, with: screen)
		item.badge = .init(count: tag.raindropCount)
		item.submenu?.update(with: raindropItems(for: tag, with: screen))
		return item
	}
	
	func raindropItems(for tag: Tag, with screen: Screen) -> [NSMenuItem] {
		if tag.loadedRaindrops.isEmpty {
			if screen.isLoadingRaindrops(tag.name) {
				[loadingItem(for: tag.name, with: screen)]
			} else {
				[emptyItem(for: tag.name, with: screen)]
			}
		} else {
			tag.loadedRaindrops.map { raindrop in
				let item = 
					tagRaindropItems[tag.name]?[raindrop.id] ??
					makeMenuItem(for: raindrop, taggedWith: tag, with: screen)
				item.title = raindrop.title
				return item
			}
		}
	}

	func makeTagsItem(with screen: Screen) -> NSMenuItem {
		let submenu = NSMenu()
		submenu.delegate = self

		let item = NSMenuItem()
		item.isEnabled = true
		item.submenu = submenu
		tagsItem = item
		return item
	}

	func makeMenuItem(for tag: Tag, with screen: Screen) -> NSMenuItem {
		let submenu = NSMenu()
		submenu.delegate = self

		let item = NSMenuItem()
		item.title = tag.name
		item.image = screen.tagIcon
		item.submenu = submenu
		item.representedObject = tag
		tagItems[tag.name] = item
		return item
	}
	
	func makeMenuItem(for raindrop: Raindrop, taggedWith tag: Tag, with screen: Screen) -> NSMenuItem {
		let item = NSMenuItem()
		item.target = self
		item.action = #selector(raindropItemSelected)
		item.representedObject = raindrop
		item.image = screen.icon(for: raindrop)
		tagRaindropItems[tag.name, default: [:]][raindrop.id] = item
		return item
	}
}

// MARK: -
@objc private extension TagList.View {
	func raindropItemSelected(item: NSMenuItem) {
		let raindrop = item.representedObject as! Raindrop
		selectRaindrop(raindrop)
	}
}

// MARK: -
extension TagList.Screen: MenuBackingScreen {
	public typealias View = TagList.View
}
