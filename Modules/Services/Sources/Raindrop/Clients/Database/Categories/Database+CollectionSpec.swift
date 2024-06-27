// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import struct Foundation.KeyPathComparator
import protocol RaindropService.CollectionSpec
import protocol DewdropService.RaindropFields
import protocol Ergo.WorkerOutput

extension Database: CollectionSpec {
	public func loadSystemCollections() async -> Self.Result<[Collection]> {
		await database.listSystemCollections().map { fields in
			fields.map(Collection.init)
		}
	}

	public func save(_ collections: [Collection]) async -> Self.Result<[Collection.ID]> {
		await database.delete(Collection.self, with: collections.map(\.id)).flatMap { _ in
			await database.insert(collections)
		}
	}
}
