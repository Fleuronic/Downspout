// Copyright © Fleuronic LLC. All rights reserved.

import SwiftSecurity

import struct DewdropDatabase.Database
import protocol Catenoid.Database

public struct Database: Sendable {
	let keychain = Keychain.default
	var database: DewdropDatabase.Database<
		RaindropListFields,
		RaindropCreationFields,
		CollectionListFields,
		ChildCollectionListFields,
		SystemCollectionListFields,
		GroupListFields,
		FilterListFields,
		TagListFields,
		HighlightListFields
	>

	public init() async {
		await database = .init()
	}
}

// MARK: -
public extension Database {
	typealias Result<Resource> = Swift.Result<Resource, Never>

	func clear() async {
		await database.clear()
	}
}
