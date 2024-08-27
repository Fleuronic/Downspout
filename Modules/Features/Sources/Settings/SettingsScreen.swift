// Copyright © Fleuronic LLC. All rights reserved.

public enum Settings {}

// MARK: -
public extension Settings {
	struct Screen {
		let logIn: () -> Void
		let logOut: () -> Void
		let deleteAccount: () -> Void
		let open: () -> Void
		let close: () -> Void
		let quit: () -> Void
		let isLoggedIn: Bool
		let isLoggedOut: Bool
	}
}

// MARK: -
extension Settings.Screen {
	var logInTitle: String { "Log in to Raindrop…" }
	var logOutTitle: String { "Log out of Raindrop" }
	var deleteAccountTitle: String { "Delete Raindrop account…" }
	var loadingTitle: String { "Loading…" }
	var quitTitle: String { "Quit Downspout" }
}
