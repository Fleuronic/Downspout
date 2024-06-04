// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import ErgoAppKit
import Raindrop

public extension GroupList {
	final class View: NSObject {
		private let emptyItem: NSMenuItem
		private let loadingItem: NSMenuItem
		private let updateGroups: () -> Void
		private let selectRaindrop: (Raindrop) -> Void

		public init(screen: Screen) {
			emptyItem = .init()
			loadingItem = .init()

			emptyItem.title = screen.emptyTitle
			loadingItem.title = screen.loadingTitle

			updateGroups = screen.updateGroups
			selectRaindrop = screen.selectRaindrop
		}
	}
}

// MARK: -

extension GroupList.View: NSMenuDelegate {
	// MARK: NSMenuDelegate

	public func menuWillOpen(_: NSMenu) {
		updateGroups()
	}
}

extension GroupList.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying

	public typealias Screen = GroupList.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		if screen.isUpdatingGroups {
			[loadingItem]
		} else if screen.groups.isEmpty {
			[emptyItem]
		} else {
			screen.groups.flatMap { group in
				let nameItem = NSMenuItem()
				nameItem.title = group.name
				nameItem.representedObject = group
				nameItem.isEnabled = false
				return [nameItem] + group.collections.map(makeMenuItem)
			}
		}
	}

	public func shouldUpdateItems(with screen: Screen, from previousScreen: Screen) -> Bool {
		if previousScreen.groups.isEmpty { return true }

		// TODO:
		return false
	}
}

// MARK: -

private extension GroupList.View {
	func makeMenuItem(for collection: Collection) -> NSMenuItem {
		let item = NSMenuItem()
		item.title = collection.name
		item.representedObject = collection

		let submenu = NSMenu()
		let collectionItems = collection.collections.map(makeMenuItem)
		let raindropItems = collection.raindrops.map(makeMenuItem)
		submenu.items = collectionItems + raindropItems

		item.submenu = submenu
		return item
	}

	func makeMenuItem(for raindrop: Raindrop) -> NSMenuItem {
		let item = NSMenuItem()
		item.title = raindrop.name
		item.representedObject = raindrop
		item.target = self
		item.action = #selector(menuItemSelected)
		return item
	}
}

@objc private extension GroupList.View {
	func menuItemSelected(item: NSMenuItem) {
		let raindrop = item.representedObject as! Raindrop
		selectRaindrop(raindrop)
	}
}

extension GroupList.Screen: MenuBackingScreen {
	public typealias View = GroupList.View
}
