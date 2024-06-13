// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Foundation.Selector
import class Foundation.NSObject
import class AppKit.NSMenuItem
import struct Identity.Identifier
import struct DewdropService.IdentifiedRaindrop

public extension RaindropList {
	protocol View: NSObject {
		associatedtype Screen: RaindropList.Screen

		var raindropAction: Selector { get }
		var raindropItems: [Raindrop.ID: NSMenuItem] { get set }
		var emptyItems: [Screen.ItemID: NSMenuItem] { get set }
		var loadingItems: [Screen.ItemID: NSMenuItem] { get set }
	}
}

public extension RaindropList.View {
	var raindropItems: [Raindrop.ID : NSMenuItem] {
		get { [:] }
		set {}
	}

	func loadingItem(for id: Screen.ItemID, with screen: Screen) -> NSMenuItem {
		loadingItems[id] ?? {
			let item = NSMenuItem()
			item.title = screen.loadingTitle
			item.isEnabled = false
			loadingItems[id] = item
			return item
		}()
	}

	func emptyItem(for id: Screen.ItemID, with screen: Screen) -> NSMenuItem {
		emptyItems[id] ?? {
			let item = NSMenuItem()
			item.title = screen.emptyTitle
			item.isEnabled = false
			emptyItems[id] = item
			return item
		}()
	}
}

public extension RaindropList.View where Screen.ItemID == Collection.ID {
	func makeMenuItem(for raindrop: Raindrop, with screen: Screen) -> NSMenuItem {
		let item = NSMenuItem()
		item.image = screen.icon(for: raindrop)
		item.target = self
		item.action = raindropAction
		item.representedObject = raindrop
		raindropItems[raindrop.id] = item
		return item
	}

	func raindropItems(for collection: Collection, with screen: Screen) -> [NSMenuItem] {
		if collection.loadedRaindrops.isEmpty {
			if screen.isUpdatingRaindrops(collection.id)  {
				[loadingItem(for: collection.id, with: screen)]
			} else {
				[emptyItem(for: collection.id, with: screen)]
			}
		} else {
			collection.loadedRaindrops.map { raindrop in
				let item = raindropItems[raindrop.id] ?? makeMenuItem(for: raindrop, with: screen)
				item.title = raindrop.title
				return item
			}
		}
	}
}
