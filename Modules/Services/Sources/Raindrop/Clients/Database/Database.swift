// Copyright © Fleuronic LLC. All rights reserved.

@preconcurrency import class Strongbox.Strongbox // TODO

import struct DewdropDatabase.Database
import protocol Catenoid.Database

public struct Database: Sendable {
	let secureStorage = Strongbox()
	let database: DewdropDatabase.Database

	public init() async {
		await database = .init()
	}
}

public extension Database {
	typealias Result<Resource> = DewdropDatabase.Database.Result<Resource>
}

extension Database: Equatable {
	public static func == (lhs: Database, rhs: Database) -> Bool {
		true
	}
}
