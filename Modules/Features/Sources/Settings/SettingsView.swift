// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import ErgoAppKit

public extension Settings {
	final class View: NSObject {
		private let loadingItem: NSMenuItem
		private let separatorItem: NSMenuItem
		private let logIn: () -> Void
		private let logOut: () -> Void
		private let quit: () -> Void

		private var items: [String: NSMenuItem] = [:]

		public init(screen: Screen) {
			loadingItem = .init()
			separatorItem = .separator()

			loadingItem.title = screen.loadingTitle
			loadingItem.isEnabled = false

			logIn = screen.logIn
			logOut = screen.logOut
			quit = screen.quit
		}
	}
}

extension Settings.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = Settings.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		[authenticationItem(with: screen), separatorItem, quitItem(with: screen)]
	}
}

private extension Settings.View {
	func authenticationItem(with screen: Screen) -> NSMenuItem {
		if screen.isLoggedIn {
			item(titled: screen.logOutTitle, for: #selector(logOut(_:)))
		} else if screen.isLoggedOut {
			item(titled: screen.logInTitle, for: #selector(logIn(_:)))
		} else {
			loadingItem
		}
	}

	func quitItem(with screen: Screen) -> NSMenuItem {
		item(titled: screen.quitTitle, for: #selector(quit(_:)))
	}

	func item(titled title: String, for action: Selector) -> NSMenuItem {
		items[title] ?? {
			let item = NSMenuItem()
			item.title = title
			item.target = self
			item.action = action
			items[title] = item
			return item
		}()
	}
}

// MARK: -
@objc private extension Settings.View {
	func logIn(_: NSMenuItem) { logIn() }
	func logOut(_: NSMenuItem) { logOut() }
	func quit(_: NSMenuItem) { quit() }
}

// MARK: -
extension Settings.Screen: MenuBackingScreen {
	public typealias View = Settings.View
}
