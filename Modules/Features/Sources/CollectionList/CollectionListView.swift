// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import ErgoAppKit

import enum RaindropList.RaindropList
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Identity.Identifier
import struct DewdropService.IdentifiedCollection

public extension CollectionList {
	final class View: NSObject {
		public var raindropItems: [Collection.Key: [Raindrop.ID: NSMenuItem]] = [:]
		public var emptyItems: [Collection.Key: NSMenuItem] = [:]
		public var loadingItems: [Collection.Key: NSMenuItem] = [:]

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

	public func menuDidClose(_ menu: NSMenu) {
		let item = menu.supermenu?.items.first { menu === $0.submenu }

		if let collection = item?.representedObject as? Collection {
			finishLoadingRaindrops(collection.id)
		}
	}
}

extension CollectionList.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = CollectionList.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		if screen.collections.isEmpty {
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
		item.image = screen.icon(for: collection)
		item.badge = .init(count: collection.count)
		item.representedObject = collection

		if let items = raindropItems(for: collection, with: screen) {
			item.submenu?.update(with: items)
		}

		return item
	}

	func makeMenuItem(for collection: Collection, with screen: Screen) -> NSMenuItem {
		let submenu = NSMenu()
		submenu.delegate = self
		
		let item = NSMenuItem()
		item.title = collection.title
		item.submenu = submenu
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
