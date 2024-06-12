// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import ErgoAppKit
import Raindrop

public extension TagList {
	final class View: NSObject {
		private let emptyItem: NSMenuItem
		private let loadingItem: NSMenuItem
		private let updateTags: () -> Void
		private let updateRaindrops: (String, Int) -> Void
		private let selectRaindrop: (Raindrop) -> Void

		private var tagsItem: NSMenuItem?
		private var tagItems: [String: NSMenuItem] = [:]
		private var tagEmptyItems: [String: NSMenuItem] = [:]
		private var tagLoadingItems: [String: NSMenuItem] = [:]
		private var tagRaindropItems: [String: [Raindrop.ID: NSMenuItem]] = [:]

		public init(screen: Screen) {
			emptyItem = .init()
			loadingItem = .init()

			emptyItem.title = screen.emptyTitle
			emptyItem.isEnabled = false
			
			loadingItem.title = screen.loadingTitle
			loadingItem.isEnabled = false
			
			updateTags = screen.updateTags
			updateRaindrops = screen.updateRaindrops
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
			updateRaindrops(tag.name, tag.raindropCount)
		} else {
			updateTags()
		}
	}
}

extension TagList.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = TagList.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		if screen.tags.isEmpty {
			return [screen.isUpdatingTags ? loadingItem : emptyItem]
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

// MARK: -
private extension TagList.View {
	func tagsItem(with screen: Screen) -> NSMenuItem {
		let item = tagsItem ?? makeTagsItem(with: screen)
		item.title = screen.tagsTitle
		return item
	}

	func tagItem(for tag: Tag, with screen: Screen) -> NSMenuItem {
		let item = tagItems[tag.name] ?? makeMenuItem(for: tag)
		item.badge = .init(count: tag.raindropCount)
		item.submenu?.update(with: raindropItems(for: tag, with: screen))
		return item
	}
	
	func raindropItems(for tag: Tag, with screen: Screen) -> [NSMenuItem] {
		if tag.loadedRaindrops.isEmpty {
			if screen.isUpdatingRaindrops(tag.name) {
				[loadingItem(for: tag, with: screen)]
			} else {
				[emptyItem(for: tag, with: screen)]
			}
		} else {
			tag.loadedRaindrops.map { raindrop in
				let item = 
					tagRaindropItems[tag.name]?[raindrop.id] ??
					makeMenuItem(for: raindrop, taggedBy: tag, with: screen)
				item.title = raindrop.title
				return item
			}
		}
	}

	func emptyItem(for tag: Tag, with screen: Screen) -> NSMenuItem {
		tagEmptyItems[tag.name] ?? {
			let item = NSMenuItem()
			item.title = screen.emptyTitle
			item.isEnabled = false
			tagEmptyItems[tag.name] = item
			return item
		}()
	}

	func loadingItem(for tag: Tag, with screen: Screen) -> NSMenuItem {
		tagLoadingItems[tag.name] ?? {
			let item = NSMenuItem()
			item.title = screen.loadingTitle
			item.isEnabled = false
			tagLoadingItems[tag.name] = item
			return item
		}()
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

	func makeMenuItem(for tag: Tag) -> NSMenuItem {
		let submenu = NSMenu()
		submenu.delegate = self

		let item = NSMenuItem()
		item.title = tag.name
		item.submenu = submenu
		item.representedObject = tag
		tagItems[tag.name] = item
		return item
	}
	
	func makeMenuItem(for raindrop: Raindrop, taggedBy tag: Tag, with screen: Screen) -> NSMenuItem {
		let item = NSMenuItem()
		item.target = self
		item.action = #selector(menuItemSelected)
		item.representedObject = raindrop
		item.image = screen.websiteIcon
		tagRaindropItems[tag.name, default: [:]][raindrop.id] = item
		return item
	}
}

// MARK: -
@objc private extension TagList.View {
	func menuItemSelected(item: NSMenuItem) {
		let raindrop = item.representedObject as! Raindrop
		selectRaindrop(raindrop)
	}
}

// MARK: -
extension TagList.Screen: MenuBackingScreen {
	public typealias View = TagList.View
}
