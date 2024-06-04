// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import class AppKit.NSMenu
import class AppKit.NSMenuItem
import protocol ErgoAppKit.MenuItemDisplaying
import protocol ErgoAppKit.MenuBackingScreen

public extension GroupList {
	final class View {
		private let selectRaindrop: (Raindrop) -> Void

		public init(screen: Screen) {
			selectRaindrop = screen.selectRaindrop
		}
	}
}

extension GroupList.View: MenuItemDisplaying {
	public typealias Screen = GroupList.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		let nameItem = NSMenuItem()
		nameItem.title = screen.name

		return [nameItem] + screen.collections.map(makeMenuItem)
	}
}

private extension GroupList.View {
	func makeMenuItem(for collection: Collection) -> NSMenuItem {
		let item = NSMenuItem()
		item.title = collection.name

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
