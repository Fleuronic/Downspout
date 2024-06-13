// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import ErgoAppKit

public extension Settings {
	final class View: NSObject {
		private let logIn: () -> Void
		private let logOut: () -> Void
		private let quit: () -> Void
		private let separatorItem: NSMenuItem

		private var items: [String: NSMenuItem] = [:]

		public init(screen: Screen) {
			logIn = screen.logIn
			logOut = screen.logOut
			quit = screen.quit
			separatorItem = .separator()
		}
	}
}

extension Settings.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = Settings.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		[
			item(titled: screen.logInTitle, for: #selector(logIn(_:))),
			separatorItem,
			item(titled: screen.quitTitle, for: #selector(quit(_:)))
		]
	}
}

private extension Settings.View {
	func item(titled title: String, for action: Selector) -> NSMenuItem {
		items[title] ?? {
			let item = NSMenuItem()
			item.title = title
			item.target = self
			item.action = action
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
