// Copyright © Fleuronic LLC. All rights reserved.

import AppKit

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Identity.Identifier
import struct DewdropService.IdentifiedRaindrop
import struct Foundation.Selector
import class Foundation.NSObject

public extension RaindropList {
	protocol View: NSObject, NSMenuDelegate {
		associatedtype Screen: RaindropList.Screen

		var raindropAction: Selector { get }
		var raindropItems: [Screen.ItemKey: [Raindrop.ID: NSMenuItem]] { get set }
		var emptyItems: [Screen.ItemKey: NSMenuItem] { get set }
		var loadingItems: [Screen.ItemKey: NSMenuItem] { get set }
		var submenus: [Screen.LoadingID: NSMenu] { get set }
	}
}

public extension RaindropList.View {
	func items(for id: Screen.ItemKey, with screen: Screen, replacingItemsIn submenu: NSMenu) -> [NSMenuItem] {
		var items = submenu.items
		if items.last?.isEnabled == false {
			items.removeLast()
			items.append(loadingItem(for: id, with: screen))
		}

		return items
	}

	// TODO: Private
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

	func makeMenuItem(for raindrop: Raindrop, keyedBy key: Screen.ItemKey, with screen: Screen) -> NSMenuItem {
		let item = NSMenuItem()
		item.image = .init(screen.icon(for: raindrop))
		item.target = self
		item.action = raindropAction
		raindropItems[key, default: [:]][raindrop.id] = item
		return item
	}

	func raindropItems(for raindrops: [Raindrop]?, keyedBy key: Screen.ItemKey, with screen: Screen) -> [NSMenuItem]? {
		raindrops.map { raindrops in
			if raindrops.isEmpty {
				[emptyItem(for: key, with: screen)]
			} else {
				raindrops.map { raindrop in
					let item =
						raindropItems[key]?[raindrop.id] ??
						makeMenuItem(for: raindrop, keyedBy: key, with: screen)
					item.title = raindrop.title
					item.representedObject = raindrop
					return item
				}
			}
		}
	}

	func submenu(for id: Screen.LoadingID) -> NSMenu {
		let submenu = submenus[id] ?? makeSubmenu(for: id)
		submenu.supermenu = nil
		return submenu
	}
}

// MARK: -
private extension RaindropList.View {
	func makeSubmenu(for id: Screen.LoadingID) -> NSMenu {
		let submenu = NSMenu()
		submenu.delegate = self
		submenus[id] = submenu
		return submenu
	}
}
