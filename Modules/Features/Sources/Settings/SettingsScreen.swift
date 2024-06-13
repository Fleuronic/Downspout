// Copyright © Fleuronic LLC. All rights reserved.

public enum Settings {}

// MARK: -
public extension Settings {
	struct Screen {
		let quit: () -> Void
	}
}

// MARK: -
extension Settings.Screen {
	var quitTitle: String { "Quit Raindropdown" }
}
