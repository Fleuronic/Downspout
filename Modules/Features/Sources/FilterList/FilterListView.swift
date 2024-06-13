// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import ErgoAppKit
import Raindrop
import enum RaindropList.RaindropList
import struct Identity.Identifier
import DewdropService

public extension FilterList {
	final class View: NSObject {
		public var emptyItems: [Filter.ID: NSMenuItem] = [:]
		public var loadingItems: [Filter.ID: NSMenuItem] = [:]

		private let emptyItem: NSMenuItem
		private let loadingItem: NSMenuItem
		private let updateFilters: () -> Void
		private let updateRaindrops: (Filter.ID, Int) -> Void
		private let selectRaindrop: (Raindrop) -> Void

		private var filtersItem: NSMenuItem?
		private var filterItems: [String: NSMenuItem] = [:]
		private var filterRaindropItems: [String: [Raindrop.ID: NSMenuItem]] = [:]

		public init(screen: Screen) {
			emptyItem = .init()
			loadingItem = .init()

			emptyItem.title = screen.emptyTitle
			emptyItem.isEnabled = false
			
			loadingItem.title = screen.loadingTitle
			loadingItem.isEnabled = false
			
			updateFilters = screen.updateFilters
			updateRaindrops = screen.updateRaindrops
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
			updateRaindrops(filter.id, filter.count)
		} else {
			updateFilters()
		}
	}
}

extension FilterList.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = FilterList.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		if screen.filters.isEmpty {
			return [screen.isUpdatingFilters ? loadingItem : emptyItem]
		} else {
			return []
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
