// Copyright © Fleuronic LLC. All rights reserved.

import SwiftSecurity

import struct DewdropDatabase.Database
import protocol Catenoid.Database

public struct Database: Sendable {
	let keychain = Keychain.default
	let database: DewdropDatabase.Database

	public init() async {
		await database = .init()
	}
}

// MARK: -
public extension Database {
	typealias Result<Resource> = DewdropDatabase.Database.Result<Resource>
}

