// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import protocol Ergo.WorkerOutput

extension Service: RaindropSpec where
	API: RaindropSpec,
	API.RaindropLoadResult == APIResult<[Raindrop]>,
	Database: RaindropSpec,
	Database.RaindropLoadResult == DatabaseResult<[Raindrop]>,
	Database.RaindropSaveResult == DatabaseResult<[Raindrop.ID]> {
	public func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) async -> Stream<API.RaindropLoadResult> {
		await load { api, database in
			await api.loadRaindrops(inCollectionWith: id, count: count).map { raindrops in
				await self.save(raindrops, inCollectionWith: id).map { _ in raindrops }.value
			}
		} databaseResult: { database in
			await database.loadRaindrops(inCollectionWith: id, count: count)
		}
	}

	public func loadRaindrops(taggedWithTagNamed name: String, count: Int) async -> Stream<API.RaindropLoadResult> {
		await load { api, _ in
			await api.loadRaindrops(taggedWithTagNamed: name, count: count)
		} databaseResult: { database in
			await database.loadRaindrops(taggedWithTagNamed: name, count: count)
		}
	}

	public func loadRaindrops(filteredByFilterWith id: Filter.ID, count: Int) async -> Stream<API.RaindropLoadResult> {
		await load { api, _ in
			await api.loadRaindrops(filteredByFilterWith: id, count: count)
		} databaseResult: { database in
			await database.loadRaindrops(filteredByFilterWith: id, count: count)
		}
	}

	public func save(_ raindrops: [Raindrop], inCollectionWith id: Collection.ID) async -> Database.RaindropSaveResult {
		await database.save(raindrops, inCollectionWith: id)
	}
}
