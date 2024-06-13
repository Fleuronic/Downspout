// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import ErgoAppKit

public extension Settings {
	final class View: NSObject {
		private var quitItem: NSMenuItem?

		private let quit: () -> Void

		public init(screen: Screen) {
			quit = screen.quit
		}
	}
}

extension Settings.View: MenuItemDisplaying {
	// MARK: MenuItemDisplaying
	public typealias Screen = Settings.Screen

	public func menuItems(with screen: Screen) -> [NSMenuItem] {
		[quitItem(with: screen)]
	}
}

private extension Settings.View {
	func quitItem(with screen: Screen) -> NSMenuItem {
		self.quitItem ?? {
			let item = NSMenuItem()
			item.title = screen.quitTitle
			item.target = self
			item.action = #selector(quitApp)
			return item
		}()
	}
}

// MARK: -
@objc private extension Settings.View {
	func quitApp() {
		quit()
	}
}

// MARK: -
extension Settings.Screen: MenuBackingScreen {
	public typealias View = Settings.View
}
