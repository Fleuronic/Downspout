// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import ErgoAppKit
import Raindrop

public extension TagList {
	final class View: NSObject {
		private let emptyItem: NSMenuItem
		private let loadingItem: NSMenuItem
		private let separatorItem: NSMenuItem
		private let updateTags: () -> Void
		private let selectRaindrop: (Raindrop) -> Void
		
		public init(screen: Screen) {
			emptyItem = .init()
			loadingItem = .init()
			separatorItem = .separator()
			
			emptyItem.title = screen.emptyTitle
			emptyItem.isEnabled = false
			
			loadingItem.title = screen.loadingTitle
			loadingItem.isEnabled = false
			
			updateTags = screen.updateTags
			selectRaindrop = screen.selectRaindrop
		}
	}
}

// MARK: -
extension TagList.View: NSMenuDelegate {
	// MARK: NSMenuDelegate
	public func menuWillOpen(_: NSMenu) {
		updateTags()
	}
}

extension TagList.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = TagList.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		let contentItems = if screen.isUpdatingTags {
			[loadingItem]
		} else if screen.tags.isEmpty {
			[emptyItem]
		} else {
			screen.tags.map(makeMenuItem)
		}
		
		return [separatorItem] + contentItems
	}

	public func shouldUpdateItems(with screen: Screen, from previousScreen: Screen) -> Bool {
		if previousScreen.tags.isEmpty { return true }
		
		// TODO:
		return false
	}
}

// MARK: -
private extension TagList.View {
	func makeMenuItem(for tag: Tag) -> NSMenuItem {
		let item = NSMenuItem()
		item.title = tag.name
		item.badge = .init(count: tag.raindropCount)
		item.representedObject = tag
		
		let submenu = NSMenu()
		submenu.items = tag.loadedRaindrops.map(makeMenuItem)
		
		item.submenu = submenu
		return item
	}

	func makeMenuItem(for raindrop: Raindrop) -> NSMenuItem {
		let item = NSMenuItem()
		item.title = raindrop.title
		item.representedObject = raindrop
		item.target = self
		item.action = #selector(menuItemSelected)
		return item
	}
}

@objc private extension TagList.View {
	func menuItemSelected(item: NSMenuItem) {
		let raindrop = item.representedObject as! Raindrop
		selectRaindrop(raindrop)
	}
}

extension TagList.Screen: MenuBackingScreen {
	public typealias View = TagList.View
}
