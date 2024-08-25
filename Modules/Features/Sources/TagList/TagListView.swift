// Copyright © Fleuronic LLC. All rights reserved.

import AppKit

import enum RaindropList.RaindropList
import struct Raindrop.Raindrop
import struct Raindrop.Tag
import struct Identity.Identifier
import struct DewdropService.IdentifiedRaindrop
import protocol ErgoAppKit.MenuItemDisplaying
import protocol ErgoAppKit.MenuBackingScreen

public extension TagList {
	final class View: NSObject {
		public var raindropItems: [Tag.Key: [Raindrop.ID: NSMenuItem]] = [:]
		public var emptyItems: [Tag.Key: NSMenuItem] = [:]
		public var loadingItems: [Tag.Key: NSMenuItem] = [:]
		public var submenus: [Tag.ID : NSMenu] = [:]

		private let loadingItem: NSMenuItem
		private let loadTags: () -> Void
		private let loadRaindrops: (Tag.ID, Int) -> Void
		private let finishLoadingRaindrops: (Tag.ID) -> Void
		private let selectRaindrop: (Raindrop) -> Void

		private var tagsItem: NSMenuItem?
		private var tagItems: [Tag.Key: NSMenuItem] = [:]

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
			loadRaindrops(tag.id, tag.count)
		} else if menu.supermenu == nil {
			loadTags()
		}
	}
}

extension TagList.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = TagList.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		if let tagsItem = tagsItem(with: screen) {
			guard !screen.tags.isEmpty else { return [] }

			tagsItem.submenu?.update(with:
				screen.tags.map { tag in
					tagItem(for: tag, with: screen)
				}
			)
			return [tagsItem]
		} else {
			return [loadingItem]
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
	func tagsItem(with screen: Screen) -> NSMenuItem? {
		guard !(screen.tags.isEmpty && screen.isLoadingTags) else { return nil }

		let item = tagsItem ?? makeTagsItem(with: screen)
		item.title = screen.tagsTitle
		return item
	}

	func tagItem(for tag: Tag, with screen: Screen) -> NSMenuItem {
		let item = tagItems[tag.key] ?? makeMenuItem(for: tag, with: screen)
		let submenu = item.submenu!
		item.badge = .init(count: tag.count)
		item.representedObject = tag

		if let items = raindropItems(for: tag.raindrops, keyedBy: tag.key, with: screen) {
			submenu.update(with: items)
		} else {
			let items = items(for: tag.key, with: screen, replacingItemsIn: submenu)
			submenu.update(with: items)
		}

		return item
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
		let item = NSMenuItem()
		item.title = tag.name
		item.image = .init(screen.tagIcon)
		item.submenu = submenu(for: tag.id)
		tagItems[tag.key] = item
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
