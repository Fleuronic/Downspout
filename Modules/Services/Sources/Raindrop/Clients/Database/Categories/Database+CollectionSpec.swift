// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import struct Raindrop.Raindrop
import protocol RaindropService.CollectionSpec
import protocol DewdropService.RaindropFields
import protocol Ergo.WorkerOutput

extension Database: CollectionSpec {
	public func loadSystemCollections() async -> Result<[Collection]> {
		await database.listSystemCollections().map { collections in
			await collections.concurrentMap { collection in
				.init(
					fields: collection,
					raindrops: await database.listRaindrops(inCollectionWith: collection.id).value.map(Raindrop.init)
				)
			}
		}
	}

	public func save(_ collections: [Collection]) async -> Result<[Collection.ID]> {
		guard !collections.isEmpty else { return .success([]) }

		return await database.delete(Collection.self, with: collections.map(\.id)).map { _ in
			await database.insert(collections).map { _ in
				await collections.concurrentMap { collection in
					await save(collection.collections)
				}.flatMap(\.value)
			}
		}.value
	}
}
