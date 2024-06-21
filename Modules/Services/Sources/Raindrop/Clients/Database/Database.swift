// Copyright © Fleuronic LLC. All rights reserved.

@preconcurrency import class Strongbox.Strongbox

import protocol Catena.Database

public struct Database: Catena.Database {
	let secureStorage = Strongbox()

	public init() {}
}

extension Database: Equatable {
	public static func == (lhs: Database, rhs: Database) -> Bool {
		true
	}
}
