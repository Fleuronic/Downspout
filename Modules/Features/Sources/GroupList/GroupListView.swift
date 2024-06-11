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
			[screen.isUpdatingGroups ? loadingItem : emptyItem]
		} else {
			screen.groups.flatMap { group in
				[menuItem(for: group)] + group.collections.map { collection in
					menuItem(for: collection, with: screen)
				}
			}
		}
	}
}

// MARK: -
private extension GroupList.View {
	func menuItem(for group: Group) -> NSMenuItem {
		groupItems[group.title] ?? makeMenuItem(for: group)
	}
	
	func menuItem(for collection: Collection, with screen: Screen) -> NSMenuItem {
		let item = collectionItems[collection.id] ?? makeMenuItem(for: collection, with: screen)
		item.title = collection.title
		item.badge = .init(count: collection.count)
		item.submenu?.update(with: submenuItems(for: collection, with: screen))
		return item
	}
	
	func submenuItems(for collection: Collection, with screen: Screen) -> [NSMenuItem] {
		let items = if collection.loadedRaindrops.isEmpty {
			[loadingItem(for: collection, with: screen)]
		} else {
			collection.loadedRaindrops.map { raindrop in
				menuItem(for: raindrop, with: screen)
			}
		}

		return items + [separatorItem(for: collection)] + collection.collections.map { collection in
			menuItem(for: collection, with: screen)
		}
	}

	func menuItem(for raindrop: Raindrop, with screen: Screen) -> NSMenuItem {
		let item = raindropItems[raindrop.id] ?? makeMenuItem(for: raindrop, with: screen)
		item.title = raindrop.title
		return item
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
		item.submenu = submenu
		item.representedObject = collection
		item.image = .init(systemSymbolName: "folder", accessibilityDescription: nil)
		collectionItems[collection.id] = item
		return item
	}
	
	func makeMenuItem(for raindrop: Raindrop, with screen: Screen) -> NSMenuItem {
		let item = NSMenuItem()
		item.target = self
		item.action = #selector(menuItemSelected)
		item.representedObject = raindrop
		item.image = .init(systemSymbolName: "globe", accessibilityDescription: nil)
		raindropItems[raindrop.id] = item
		return item
	}
}

@objc private extension GroupList.View {
	func menuItemSelected(item: NSMenuItem) {
		let raindrop = item.representedObject as! Raindrop
		selectRaindrop(raindrop)
	}
}

extension GroupList.Screen: MenuBackingScreen {
	public typealias View = GroupList.View
}
