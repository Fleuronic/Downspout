// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Foundation.URL
import protocol Ergo.WorkerOutput

extension Service: RaindropSpec where
	API: RaindropSpec,
	API.RaindropLoadResult == APIResult<[Raindrop]>,
	Database: RaindropSpec,
	Database.RaindropLoadResult == DatabaseResult<[Raindrop]>,
	Database.RaindropSaveResult == DatabaseResult<[Raindrop.ID]> {
	public func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) async -> API.RaindropLoadResult {
		await api.loadRaindrops(inCollectionWith: id, count: count).map { raindrops in
			await self.database.save(raindrops, inCollectionWith: id).map { _ in raindrops }.value
		}
	}

	public func loadRaindrops(filteredByFilterWith id: Filter.ID, count: Int) async -> API.RaindropLoadResult {
		await api.loadRaindrops(filteredByFilterWith: id, count: count).map { raindrops in
			await self.database.save(raindrops, filteredByFilterWith: id).map { _ in raindrops }.value
		}
	}

	public func loadRaindrops(taggedWithTagNamed name: String, count: Int) async -> API.RaindropLoadResult {
		await api.loadRaindrops(taggedWithTagNamed: name, count: count).map { raindrops in
			await self.database.save(raindrops, taggedWithTagNamed: name).map { _ in raindrops }.value
		}
	}
}
