// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import protocol Ergo.WorkerOutput

extension Service: CollectionSpec where
	API: CollectionSpec,
	API.CollectionLoadResult == APIResult<[Collection]>,
	Database: CollectionSpec,
	Database.CollectionLoadResult == DatabaseResult<[Collection]>,
	Database.CollectionSaveResult == DatabaseResult<[Collection.ID]>{
	public func loadSystemCollections() async -> Stream<API.CollectionLoadResult> {
		await load { api, database in
			await api.loadSystemCollections().map { collections in
				await self.save(collections).map { _ in collections }.value
			}
		} databaseResult: { database in
			await database.loadSystemCollections()
		}
	}

	public func save(_ collections: [Collection]) async -> Database.CollectionSaveResult {
		await database.save(collections)
	}
}
