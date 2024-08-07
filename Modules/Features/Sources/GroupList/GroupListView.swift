// Copyright © Fleuronic LLC. All rights reserved.

import AppKit

import enum RaindropList.RaindropList
import struct Raindrop.Group
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import struct Identity.Identifier
import struct DewdropService.IdentifiedCollection
import protocol ErgoAppKit.MenuItemDisplaying
import protocol ErgoAppKit.MenuBackingScreen

public extension GroupList {
	final class View: NSObject {
		public var raindropItems: [Collection.Key: [Raindrop.ID: NSMenuItem]] = [:]
		public var emptyItems: [Collection.Key: NSMenuItem] = [:]
		public var loadingItems: [Collection.Key: NSMenuItem] = [:]
		public var submenus: [Collection.ID: NSMenu] = [:]

		private let loadingItem: NSMenuItem
		private let loadGroups: () -> Void
		private let loadRaindrops: (Collection.ID, Int) -> Void
		private let selectRaindrop: (Raindrop) -> Void
		
		private var groupItems: [Group.Key: NSMenuItem] = [:]
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
		let item = groupItems[group.key] ?? makeMenuItem(for: group)
		item.representedObject = group
		return item
	}
	
	func collectionItems(for collections: [Collection], with screen: Screen) -> [NSMenuItem] {
		collections.map { collection in
			let item = collectionItems[collection.key] ?? makeMenuItem(for: collection, with: screen)
			let submenu = item.submenu!
			
			item.title = collection.title
			item.image = .init(screen.icon(for: collection))
			item.representedObject = collection

			if let raindropItems = raindropItems(for: collection, with: screen) {
				let collectionItems = collectionItems(for: collection.collections, with: screen)
				let separatorItems = [separatorItem(for: collection)]
				submenu.update(with: collectionItems + separatorItems + raindropItems)
			} else {
				let items = items(for: collection.key, with: screen, replacingItemsIn: submenu)
				submenu.update(with: items)
			}

			return item
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
		groupItems[group.key] = item
		return item
	}
	
	func makeMenuItem(for collection: Collection, with screen: Screen) -> NSMenuItem {
		let item = NSMenuItem()
		item.badge = .init(count: collection.count)
		item.submenu = submenu(for: collection.id)
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
