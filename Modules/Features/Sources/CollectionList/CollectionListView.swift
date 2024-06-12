// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import ErgoAppKit
import Raindrop

public extension CollectionList {
	final class View: NSObject {
		private let loadingItem: NSMenuItem
		private let updateCollections: () -> Void
		private let updateRaindrops: (Collection.ID, Int) -> Void
		private let selectRaindrop: (Raindrop) -> Void
		
		private var raindropItems: [Raindrop.ID: NSMenuItem] = [:]
		private var collectionItems: [Collection.ID: NSMenuItem] = [:]
		private var collectionEmptyItems: [Collection.ID: NSMenuItem] = [:]
		private var collectionLoadingItems: [Collection.ID: NSMenuItem] = [:]
		
		public init(screen: Screen) {
			loadingItem = .init()
			
			loadingItem.title = screen.loadingTitle
			loadingItem.isEnabled = false
			
			updateCollections = screen.updateCollections
			updateRaindrops = screen.updateRaindrops
			selectRaindrop = screen.selectRaindrop
		}
	}
}

// MARK: -
extension CollectionList.View: NSMenuDelegate {
	// MARK: NSMenuDelegate
	public func menuWillOpen(_ menu: NSMenu) {
		let item = menu.supermenu?.items.first { menu === $0.submenu }

		if let collection = item?.representedObject as? Collection {
			updateRaindrops(collection.id, collection.count)
		} else {
			updateCollections()
		}
	}
}

extension CollectionList.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = CollectionList.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		if screen.isUpdatingCollections {
			[loadingItem]
		} else {
			screen.collections.map { collection in
				collectionItem(for: collection, with: screen)
			}
		}
	}
}

// MARK: -
private extension CollectionList.View {
	func collectionItem(for collection: Collection, with screen: Screen) -> NSMenuItem {
		let item = collectionItems[collection.id] ?? makeMenuItem(for: collection, with: screen)
		item.submenu?.update(with: raindropItems(for: collection, with: screen))
		return item
	}
	
	func raindropItems(for collection: Collection, with screen: Screen) -> [NSMenuItem] {
		if collection.loadedRaindrops.isEmpty {
			if screen.isUpdatingRaindrops(collection.id)  {
				[loadingItem(for: collection, with: screen)]
			} else {
				[emptyItem(for: collection, with: screen)]
			}
		} else {
			collection.loadedRaindrops.map { raindrop in
				let item = raindropItems[raindrop.id] ?? makeMenuItem(for: raindrop, with: screen)
				item.title = raindrop.title
				return item
			}
		}
	}
	
	func emptyItem(for collection: Collection, with screen: Screen) -> NSMenuItem {
		collectionEmptyItems[collection.id] ?? {
			let item = NSMenuItem()
			item.title = screen.emptyTitle
			item.isEnabled = false
			collectionEmptyItems[collection.id] = item
			return item
		}()
	}	
	
	func loadingItem(for collection: Collection, with screen: Screen) -> NSMenuItem {
		collectionLoadingItems[collection.id] ?? {
			let item = NSMenuItem()
			item.title = screen.loadingTitle
			item.isEnabled = false
			collectionLoadingItems[collection.id] = item
			return item
		}()
	}

	func makeMenuItem(for collection: Collection, with screen: Screen) -> NSMenuItem {
		let submenu = NSMenu()
		submenu.delegate = self
		
		let item = NSMenuItem()
		item.title = collection.title
		item.image = screen.icon(for: collection)
		item.submenu = submenu
		item.representedObject = collection
		collectionItems[collection.id] = item
		return item
	}
	
	func makeMenuItem(for raindrop: Raindrop, with screen: Screen) -> NSMenuItem {
		let item = NSMenuItem()
		item.image = screen.icon(for: raindrop)
		item.target = self
		item.action = #selector(menuItemSelected)
		item.representedObject = raindrop
		raindropItems[raindrop.id] = item
		return item
	}
}
// MARK: -
@objc private extension CollectionList.View {
	func menuItemSelected(item: NSMenuItem) {
		let raindrop = item.representedObject as! Raindrop
		selectRaindrop(raindrop)
	}
}

// MARK: -
extension CollectionList.Screen: MenuBackingScreen {
	public typealias View = CollectionList.View
}
