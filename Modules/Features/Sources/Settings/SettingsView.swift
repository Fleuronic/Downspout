// Copyright © Fleuronic LLC. All rights reserved.

import AppKit

import protocol ErgoAppKit.MenuItemDisplaying
import protocol ErgoAppKit.MenuBackingScreen

public extension Settings {
	final class View: NSObject {
		private let loadingItem: NSMenuItem
		private let logIn: () -> Void
		private let logOut: () -> Void
		private let deleteAccount: () -> Void
		private let open: () -> Void
		private let close: () -> Void
		private let quit: () -> Void

		private var items: [String: NSMenuItem] = [:]

		public init(screen: Screen) {
			loadingItem = .init()
			loadingItem.title = screen.loadingTitle
			loadingItem.isEnabled = false

			logIn = screen.logIn
			logOut = screen.logOut
			deleteAccount = screen.deleteAccount
			open = screen.open
			close = screen.close
			quit = screen.quit
		}
	}
}

// MARK: -
extension Settings.View: NSMenuDelegate {
	// MARK: NSMenuDelegate
	public func menuWillOpen(_ menu: NSMenu) {
		open()
	}

	public func menuDidClose(_ menu: NSMenu) {
		close()
	}
}

extension Settings.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = Settings.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		[
			authenticationItems(with: screen),
			[quitItem(with: screen)]
		].flatMap { $0 }
	}
}

// MARK: -
private extension Settings.View {
	func authenticationItems(with screen: Screen) -> [NSMenuItem] {
		if screen.isLoggedIn {
			[
				item(titled: screen.logOutTitle, for: #selector(logOut(_:))),
				item(titled: screen.deleteAccountTitle, for: #selector(deleteAccount(_:)))
			]
		} else if screen.isLoggedOut {
			[item(titled: screen.logInTitle, for: #selector(logIn(_:)))]
		} else {
			[loadingItem]
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
	func deleteAccount(_: NSMenuItem) { deleteAccount() }
	func quit(_: NSMenuItem) { quit() }
}

// MARK: -
extension Settings.Screen: MenuBackingScreen {
	public typealias View = Settings.View
}
