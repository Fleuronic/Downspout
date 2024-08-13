// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Raindrop.Tag
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
		let existingIDs = await database.listRaindrops(inCollectionWith: id).value.map(\.id)
		let replacementIDs = raindrops.map(\.id)

		return await database.delete(Raindrop.self, with: existingIDs).flatMap { _ in
			await database.delete(Raindrop.self, with: replacementIDs)
		}.flatMap { _ in
			await database.insert(raindrops)
		}
	}

	public func save(_ raindrops: [Raindrop], filteredByFilterWith id: Filter.ID) async -> Result<[Raindrop.ID]> {
		// TODO: Deletes too many (after saving highlighted raindrops, removes most others from DB2
		let query = Filter.query(for: id)
		let existingIDs = await database.listRaindrops(searchingFor: query).value.map(\.id)
		let replacementIDs = raindrops.map(\.id)

		return await database.delete(Raindrop.self, with: existingIDs).flatMap { _ in
			await database.delete(Raindrop.self, with: replacementIDs)
		}.flatMap { _ in
			await database.insert(raindrops)
		}
	}
}
