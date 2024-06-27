// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Raindrop.Tag
import protocol RaindropService.RaindropSpec
import protocol DewdropService.RaindropFields
import protocol Ergo.WorkerOutput

extension Database: RaindropSpec {
	public func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) async -> Self.Result<[Raindrop]> {
		await database.listRaindrops(inCollectionWith: id).map { fields in
			fields.map(Raindrop.init)
		}
	}

	public func loadRaindrops(taggedWithTagNamed name: String, count: Int) async -> Self.Result<[Raindrop]> {
		.success([])
	}

	public func loadRaindrops(filteredByFilterWith id: Filter.ID, count: Int) async -> Self.Result<[Raindrop]> {
		.success([])
	}

	public func save(_ raindrops: [Raindrop], inCollectionWith id: Collection.ID) async -> Self.Result<[Raindrop.ID]> {
		await database.delete(Raindrop.self, with: raindrops.map(\.id)).flatMap { _ in
			await database.insert(raindrops)
		}
	}
}
