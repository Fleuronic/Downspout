// Copyright © Fleuronic LLC. All rights reserved.

import AppKit

import enum RaindropList.RaindropList
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Identity.Identifier
import struct DewdropService.IdentifiedRaindrop
import protocol ErgoAppKit.MenuItemDisplaying
import protocol ErgoAppKit.MenuBackingScreen

public extension CollectionList {
	final class View: NSObject {
		public var raindropItems: [Collection.Key: [Raindrop.ID: NSMenuItem]] = [:]
		public var emptyItems: [Collection.Key: NSMenuItem] = [:]
		public var loadingItems: [Collection.Key: NSMenuItem] = [:]
		public var submenus: [Collection.ID: NSMenu] = [:]

		private let loadingItem: NSMenuItem
		private let loadCollections: () -> Void
		private let loadRaindrops: (Collection.ID, Int) -> Void
		private let finishLoadingRaindrops: (Collection.ID) -> Void
		private let selectRaindrop: (Raindrop) -> Void

		private var collectionItems: [Collection.Key: NSMenuItem] = [:]

		public init(screen: Screen) {
			loadingItem = .init()
			loadingItem.title = screen.loadingTitle
			loadingItem.isEnabled = false

			loadCollections = screen.loadCollections
			finishLoadingRaindrops = screen.finishLoadingRaindrops
			loadRaindrops = screen.loadRaindrops
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
			loadRaindrops(collection.id, collection.count)
		} else {
			loadCollections()
		}
	}
}

extension CollectionList.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = CollectionList.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		if screen.collections.isEmpty && screen.isLoadingCollections {
			[loadingItem]
		} else {
			screen.collections.map { collection in
				collectionItem(for: collection, with: screen)
			}
		}
	}
}

extension CollectionList.View: RaindropList.View {
	public var raindropAction: Selector {
		#selector(raindropItemSelected)
	}
}

// MARK: -
private extension CollectionList.View {
	func collectionItem(for collection: Collection, with screen: Screen) -> NSMenuItem {
		let item = collectionItems[collection.key] ?? makeMenuItem(for: collection, with: screen)
		let submenu = item.submenu!		
		item.badge = .init(count: collection.count)
		item.representedObject = collection

		if let items = raindropItems(for: collection.raindrops, keyedBy: collection.key, with: screen) {
			submenu.update(with: items)
		} else {
			let items = items(for: collection.key, with: screen, replacingItemsIn: submenu)
			submenu.update(with: items)
		}

		return item
	}

	func makeMenuItem(for collection: Collection, with screen: Screen) -> NSMenuItem {
		let item = NSMenuItem()
		item.title = collection.title
		item.image = .init(screen.icon(for: collection))
		item.submenu = submenu(for: collection.id)
		collectionItems[collection.key] = item
		return item
	}
}

// MARK: -
@objc private extension CollectionList.View {
	func raindropItemSelected(item: NSMenuItem) {
		let raindrop = item.representedObject as! Raindrop
		selectRaindrop(raindrop)
	}
}

// MARK: -
extension CollectionList.Screen: MenuBackingScreen {
	public typealias View = CollectionList.View
}
