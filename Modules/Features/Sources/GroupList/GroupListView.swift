// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import ErgoAppKit

import enum RaindropList.RaindropList
import struct Raindrop.Group
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import struct Identity.Identifier

public extension GroupList {
	final class View: NSObject {
		public var raindropItems: [Collection.ID: [Raindrop.ID: NSMenuItem]] = [:]
		public var emptyItems: [Collection.ID: NSMenuItem] = [:]
		public var loadingItems: [Collection.ID: NSMenuItem] = [:]

		private let loadGroups: () -> Void
		private let loadRaindrops: (Collection.ID, Int) -> Void
		private let selectRaindrop: (Raindrop) -> Void
		
		private var groupItems: [String: NSMenuItem] = [:]
		private var collectionItems: [Collection.ID: NSMenuItem] = [:]
		private var separatorItems: [Collection.ID: NSMenuItem] = [:]

		public init(screen: Screen) {
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
		screen.groups.flatMap { group in
			[groupItem(for: group)] + collectionItems(for: group.collections, with: screen)
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
		groupItems[group.title] ?? makeMenuItem(for: group)
	}
	
	func collectionItems(for collections: [Collection], with screen: Screen) -> [NSMenuItem] {
		collections.map { collection in
			let item = collectionItems[collection.id] ?? makeMenuItem(for: collection, with: screen)
			item.title = collection.title
			item.badge = .init(count: collection.count)
			item.submenu?.update(with: items(for: collection, with: screen))
			return item
		}
	}

	func items(for collection: Collection, with screen: Screen) -> [NSMenuItem] {
		let collectionItems = collectionItems(for: collection.collections, with: screen)
		let raindropItems = raindropItems(for: collection, with: screen)
		let separatorItems = [separatorItem(for: collection)]
		return collectionItems + separatorItems + raindropItems
	}

	func separatorItem(for collection: Collection) -> NSMenuItem {
		separatorItems[collection.id] ?? {
			let item = NSMenuItem.separator()
			separatorItems[collection.id] = item
			return item
		}()
	}
	
	func makeMenuItem(for group: Group) -> NSMenuItem {
		let item = NSMenuItem()
		item.title = group.title
		item.isEnabled = false
		item.representedObject = group
		groupItems[group.title] = item
		return item
	}
	
	func makeMenuItem(for collection: Collection, with screen: Screen) -> NSMenuItem {
		let submenu = NSMenu()
		submenu.delegate = self
		
		let item = NSMenuItem()
		item.image = screen.icon(for: collection)
		item.submenu = submenu
		item.representedObject = collection
		collectionItems[collection.id] = item
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
