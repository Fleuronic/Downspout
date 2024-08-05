// Copyright © Fleuronic LLC. All rights reserved.

import AppKit

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Foundation.Selector
import class Foundation.NSObject
import struct Identity.Identifier
import struct DewdropService.IdentifiedCollection

public extension RaindropList {
	protocol View: NSObject, NSMenuDelegate {
		associatedtype Screen: RaindropList.Screen

		var raindropAction: Selector { get }
		var raindropItems: [Collection.Key: [Raindrop.ID: NSMenuItem]] { get set }
		var emptyItems: [Screen.ItemKey: NSMenuItem] { get set }
		var loadingItems: [Screen.ItemKey: NSMenuItem] { get set }
		var submenus: [Screen.LoadingID: NSMenu] { get set }
	}
}

public extension RaindropList.View {
	var raindropItems: [Collection.Key: [Raindrop.ID : NSMenuItem]] {
		get { [:] }
		set {}
	}

	func loadingItem(for id: Screen.ItemKey, with screen: Screen) -> NSMenuItem {
		loadingItems[id] ?? {
			let item = NSMenuItem()
			item.title = screen.loadingTitle
			item.isEnabled = false
			loadingItems[id] = item
			return item
		}()
	}

	func emptyItem(for id: Screen.ItemKey, with screen: Screen) -> NSMenuItem {
		return emptyItems[id] ?? {
			let item = NSMenuItem()
			item.title = screen.emptyTitle
			item.isEnabled = false
			emptyItems[id] = item
			return item
		}()
	}
}

public extension RaindropList.View {
	func submenu(for id: Screen.LoadingID) -> NSMenu {
		let submenu = submenus[id] ?? makeSubmenu(for: id)
		submenu.supermenu = nil
		return submenu
	}
}

public extension RaindropList.View where Screen.ItemKey == Collection.Key {
	func makeMenuItem(for raindrop: Raindrop, in collection: Collection, with screen: Screen) -> NSMenuItem {
		let item = NSMenuItem()
		item.image = .init(screen.icon(for: raindrop))
		item.target = self
		item.action = raindropAction
		raindropItems[collection.key, default: [:]][raindrop.id] = item
		return item
	}

	func raindropItems(for collection: Collection, with screen: Screen) -> [NSMenuItem]? {
		collection.raindrops.map { raindrops in
			if raindrops.isEmpty {
				[emptyItem(for: collection.key, with: screen)]
			} else {
				raindrops.map { raindrop in
					let item =
						raindropItems[collection.key]?[raindrop.id] ??
						makeMenuItem(for: raindrop, in: collection, with: screen)
					item.title = raindrop.title
					item.representedObject = raindrop
					return item
				}
			}
		}
	}
}

private extension RaindropList.View {
	func makeSubmenu(for id: Screen.LoadingID) -> NSMenu {
		let submenu = NSMenu()
		submenu.delegate = self
		submenus[id] = submenu
		return submenu
	}
}
