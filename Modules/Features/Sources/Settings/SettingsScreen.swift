// Copyright © Fleuronic LLC. All rights reserved.

public enum Settings {}

// MARK: -
public extension Settings {
	struct Screen {
		let logIn: () -> Void
		let logOut: () -> Void
		let quit: () -> Void
	}
}

// MARK: -
extension Settings.Screen {
	var logInTitle: String { "Log in to Raindrop…" }
	var logOutTitle: String { "Log out of Raindrop" }
	var quitTitle: String { "Quit Raindropdown" }
}
