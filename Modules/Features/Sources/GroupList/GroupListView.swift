// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import ErgoAppKit

import enum RaindropList.RaindropList
import struct Raindrop.Group
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import struct Identity.Identifier
import struct DewdropService.IdentifiedCollection

public extension GroupList {
	final class View: NSObject {
		public var raindropItems: [Collection.Key: [Raindrop.ID: NSMenuItem]] = [:]
		public var emptyItems: [Collection.Key: NSMenuItem] = [:]
		public var loadingItems: [Collection.Key: NSMenuItem] = [:]

		private let loadingItem: NSMenuItem
		private let loadGroups: () -> Void
		private let loadRaindrops: (Collection.ID, Int) -> Void
		private let selectRaindrop: (Raindrop) -> Void
		
		private var groupItems: [String: NSMenuItem] = [:]
		private var collectionItems: [Collection.Key: NSMenuItem] = [:]
		private var separatorItems: [Collection.Key: NSMenuItem] = [:]

		public init(screen: Screen) {
			loadingItem = .init()
			loadingItem.title = screen.loadingTitle
			loadingItem.isEnabled = false

			loadGroups = screen.loadGroups
			loadRaindrops = screen.loadRaindrops
			selectRaindrop = screen.selectRaindrop
		}
	}
}

// MARK: -
extension GroupList.View: NSMenuDelegate {
	// MARK: NSMenuDelegate
	public func menuWillOpen(_ menu: NSMenu) {
		let item = menu.supermenu?.items.first { menu === $0.submenu }

		if let collection = item?.representedObject as? Collection {
			loadRaindrops(collection.id, collection.count)
		} else {
			loadGroups()
		}
	}
}

extension GroupList.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = GroupList.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		if screen.groups.isEmpty {
			[loadingItem]
		} else {
			screen.groups.flatMap { group in
				[groupItem(for: group)] + collectionItems(for: group.collections, with: screen)
			}
		}
	}
}

extension GroupList.View: RaindropList.View {
	public var raindropAction: Selector {
		#selector(raindropItemSelected)
	}
}

// MARK: -
private extension GroupList.View {
	func groupItem(for group: Group) -> NSMenuItem {
		let item = groupItems[group.title] ?? makeMenuItem(for: group)
		item.representedObject = group
		return item
	}
	
	func collectionItems(for collections: [Collection], with screen: Screen) -> [NSMenuItem] {
		collections.map { collection in
			let item = collectionItems[collection.key] ?? makeMenuItem(for: collection, with: screen)
			item.title = collection.title
			item.image = screen.icon(for: collection)
			item.badge = .init(count: collection.count)
			item.representedObject = collection
			item.submenu?.update(with: items(for: collection, with: screen, replacing: item.submenu?.items))
			return item
		}
	}

	func items(for collection: Collection, with screen: Screen, replacing items: [NSMenuItem]?) -> [NSMenuItem] {
		let collectionItems = collectionItems(for: collection.collections, with: screen)
		let separatorItems = [separatorItem(for: collection)]
		let raindropItems = raindropItems(for: collection, with: screen) ?? items?.filter { item in
			item.representedObject is Raindrop ||
			emptyItems.values.contains(item) ||
			loadingItems.values.contains(item)
		} ?? []

		return collectionItems + separatorItems + raindropItems.map { item in
			if item === emptyItem(for: collection.key, with: screen) && screen.isLoadingRaindrops(collection.id) {
				loadingItem(for: collection.key, with: screen)
			} else {
				item
			}
		}
	}

	func separatorItem(for collection: Collection) -> NSMenuItem {
		separatorItems[collection.key] ?? {
			let item = NSMenuItem.separator()
			separatorItems[collection.key] = item
			return item
		}()
	}
	
	func makeMenuItem(for group: Group) -> NSMenuItem {
		let item = NSMenuItem()
		item.title = group.title
		item.isEnabled = false
		groupItems[group.title] = item
		return item
	}
	
	func makeMenuItem(for collection: Collection, with screen: Screen) -> NSMenuItem {
		let submenu = NSMenu()
		submenu.delegate = self
		
		let item = NSMenuItem()
		item.submenu = submenu
		collectionItems[collection.key] = item
		return item
	}
}

// MARK: -
@objc private extension GroupList.View {
	func raindropItemSelected(item: NSMenuItem) {
		let raindrop = item.representedObject as! Raindrop
		selectRaindrop(raindrop)
	}
}

// MARK: -
extension GroupList.Screen: MenuBackingScreen {
	public typealias View = GroupList.View
}
