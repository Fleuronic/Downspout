// Copyright © Fleuronic LLC. All rights reserved.

import AppKit

import enum RaindropList.RaindropList
import struct Raindrop.Filter
import struct Raindrop.Raindrop
import struct Identity.Identifier
import struct DewdropService.IdentifiedRaindrop
import protocol ErgoAppKit.MenuItemDisplaying
import protocol ErgoAppKit.MenuBackingScreen

public extension FilterList {
	final class View: NSObject {
		public var raindropItems: [Filter.Key: [Raindrop.ID: NSMenuItem]] = [:]
		public var emptyItems: [Filter.Key: NSMenuItem] = [:]
		public var loadingItems: [Filter.Key: NSMenuItem] = [:]
		public var submenus: [Filter.ID : NSMenu] = [:]

		private let loadFilters: () -> Void
		private let loadRaindrops: (Filter.ID, Int) -> Void
		private let selectRaindrop: (Raindrop) -> Void

		private var filterItems: [Filter.Key: NSMenuItem] = [:]

		public init(screen: Screen) {
			loadFilters = screen.loadFilters
			loadRaindrops = screen.loadRaindrops
			selectRaindrop = screen.selectRaindrop
		}
	}
}

// MARK: -
extension FilterList.View: NSMenuDelegate {
	// MARK: NSMenuDelegate
	public func menuWillOpen(_ menu: NSMenu) {
		let item = menu.supermenu?.items.first { menu === $0.submenu }
		
		if let filter = item?.representedObject as? Filter {
			loadRaindrops(filter.id, filter.count)
		} else {
			loadFilters()
		}
	}
}

extension FilterList.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = FilterList.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		screen.filters.map { filter in
			filterItem(for: filter, with: screen)
		}
	}
}

extension FilterList.View: RaindropList.View {
	public var raindropAction: Selector {
		#selector(raindropItemSelected)
	}
}

// MARK: -
private extension FilterList.View {
	func filterItem(for filter: Filter, with screen: Screen) -> NSMenuItem {
		let item = filterItems[filter.key] ?? makeMenuItem(for: filter, with: screen)
		let submenu = item.submenu!
		item.badge = .init(count: filter.count)
		item.representedObject = filter

		if let items = raindropItems(for: filter.raindrops, keyedBy: filter.key, with: screen) {
			submenu.update(with: items)
		} else {
			let items = items(for: filter.key, with: screen, replacingItemsIn: submenu)
			submenu.update(with: items)
		}

		return item
	}

	func makeMenuItem(for filter: Filter, with screen: Screen) -> NSMenuItem {
		let item = NSMenuItem()
		item.title = screen.title(for: filter)
		item.image = .init(screen.icon(for: filter))
		item.submenu = submenu(for: filter.id)
		filterItems[filter.key] = item
		return item
	}
}

// MARK: -
@objc private extension FilterList.View {
	func raindropItemSelected(item: NSMenuItem) {
		let raindrop = item.representedObject as! Raindrop
		selectRaindrop(raindrop)
	}
}

// MARK: -
extension FilterList.Screen: MenuBackingScreen {
	public typealias View = FilterList.View
}
