// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import ErgoAppKit

import enum RaindropList.RaindropList
import struct Raindrop.Raindrop
import struct Raindrop.Filter
import struct Identity.Identifier

public extension FilterList {
	final class View: NSObject {
		public var emptyItems: [Filter.Key: NSMenuItem] = [:]
		public var loadingItems: [Filter.Key: NSMenuItem] = [:]

		private let loadFilters: () -> Void
		private let loadRaindrops: (Filter.ID, Int) -> Void
		private let selectRaindrop: (Raindrop) -> Void

		private var filterItems: [Filter.ID: NSMenuItem] = [:]
		private var filterRaindropItems: [Filter.ID: [Raindrop.ID: NSMenuItem]] = [:]

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
		let item = filterItems[filter.id] ?? makeMenuItem(for: filter, with: screen)
		item.badge = .init(count: filter.count)
		item.representedObject = filter
		item.submenu?.update(with: raindropItems(for: filter, with: screen))
		return item
	}

	func raindropItems(for filter: Filter, with screen: Screen) -> [NSMenuItem] {
		let raindrops = filter.raindrops ?? []
		return if raindrops.isEmpty {
			if screen.isLoadingRaindrops(filter.id) {
				[loadingItem(for: filter.key, with: screen)]
			} else {
				[emptyItem(for: filter.key, with: screen)]
			}
		} else {
			raindrops.map { raindrop in
				let item =
					filterRaindropItems[filter.id]?[raindrop.id] ??
					makeMenuItem(for: raindrop, filteredBy: filter, with: screen)
				item.title = raindrop.title
				item.representedObject = raindrop
				return item
			}
		}
	}

	func makeMenuItem(for filter: Filter, with screen: Screen) -> NSMenuItem {
		let submenu = NSMenu()
		submenu.delegate = self

		let item = NSMenuItem()
		item.title = screen.title(for: filter)
		item.image = screen.icon(for: filter)
		item.submenu = submenu
		filterItems[filter.id] = item
		return item
	}

	func makeMenuItem(for raindrop: Raindrop, filteredBy filter: Filter, with screen: Screen) -> NSMenuItem {
		let item = NSMenuItem()
		item.target = self
		item.action = #selector(raindropItemSelected)
		item.image = screen.icon(for: raindrop)
		filterRaindropItems[filter.id, default: [:]][raindrop.id] = item
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
