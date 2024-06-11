// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import ErgoAppKit
import Raindrop

public extension GroupList {
	final class View: NSObject {
		private let emptyItem: NSMenuItem
		private let loadingItem: NSMenuItem
		private let updateGroups: () -> Void
		private let updateRaindrops: (Collection.ID) -> Void
		private let selectRaindrop: (Raindrop) -> Void
		
		private var groupItems: [String: NSMenuItem] = [:]
		private var raindropItems: [Raindrop.ID: NSMenuItem] = [:]
		private var collectionItems: [Collection.ID: NSMenuItem] = [:]
		private var collectionEmptyItems: [Collection.ID: NSMenuItem] = [:]
		private var collectionLoadingItems: [Collection.ID: NSMenuItem] = [:]
		private var collectionSeparatorItems: [Collection.ID: NSMenuItem] = [:]
		
		public init(screen: Screen) {
			emptyItem = .init()
			loadingItem = .init()
			
			emptyItem.title = screen.emptyTitle
			emptyItem.isEnabled = false
			
			loadingItem.title = screen.loadingTitle
			loadingItem.isEnabled = false
			
			updateGroups = screen.updateGroups
			updateRaindrops = screen.updateRaindrops
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
			updateRaindrops(collection.id)
		} else {
			updateGroups()
		}
	}
}

extension GroupList.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = GroupList.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		if screen.groups.isEmpty {
			if screen.isUpdatingGroups  {
				[loadingItem]
			} else {
				[emptyItem]
			}
		} else {
			screen.groups.flatMap { group in
				[groupItem(for: group)] + collectionItems(for: group.collections, with: screen)
			}
		}
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
	
	func items(for collection: Collection, with screen: Screen) -> [NSMenuItem] {
		let collectionItems = collectionItems(for: collection.collections, with: screen)
		let raindropItems = raindropItems(for: collection, with: screen)
		let separatorItems = [separatorItem(for: collection)]
		return collectionItems + separatorItems + raindropItems
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
	
	func separatorItem(for collection: Collection) -> NSMenuItem {
		collectionSeparatorItems[collection.id] ?? {
			let item = NSMenuItem.separator()
			collectionSeparatorItems[collection.id] = item
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
@objc private extension GroupList.View {
	func menuItemSelected(item: NSMenuItem) {
		let raindrop = item.representedObject as! Raindrop
		selectRaindrop(raindrop)
	}
}

// MARK: -
extension GroupList.Screen: MenuBackingScreen {
	public typealias View = GroupList.View
}
