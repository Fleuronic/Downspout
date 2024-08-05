// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Raindrop.Tag
import struct Catena.IDFields
import protocol RaindropService.RaindropSpec
import protocol DewdropService.RaindropFields
import protocol Ergo.WorkerOutput

extension Database: RaindropSpec {
	public func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) -> Result<[Raindrop]> {
		.success([])
	}

	public func loadRaindrops(taggedWithTagNamed name: String, count: Int) -> Result<[Raindrop]> {
		.success([])
	}

	public func loadRaindrops(filteredByFilterWith id: Filter.ID, count: Int) -> Result<[Raindrop]> {
		.success([])
	}

	public func save(_ raindrops: [Raindrop], inCollectionWith id: Collection.ID) async -> Result<[Raindrop.ID]> {
		let ids = await database.fetch(where: id.containsRaindrop).value.map(\IDFields<Raindrop.Identified>.id)
		return await database.delete(Raindrop.self, with: ids).flatMap { _ in
			await database.delete(Raindrop.self, with: raindrops.map(\.id))
		}.flatMap { _ in
			await database.insert(raindrops)
		}
	}
}
