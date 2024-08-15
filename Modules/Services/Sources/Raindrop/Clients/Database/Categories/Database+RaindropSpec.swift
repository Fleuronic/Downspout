// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.Filter
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Raindrop.Tag
import protocol RaindropService.RaindropSpec
import protocol DewdropService.RaindropFields
import protocol Ergo.WorkerOutput

extension Database: RaindropSpec {
	public func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) async -> Result<[Raindrop]> {
		await database.listRaindrops(inCollectionWith: id).map { raindrops in
			raindrops.map(Raindrop.init)
		}
	}

	public func loadRaindrops(taggedWithTagNamed name: String, count: Int) -> Result<[Raindrop]> {
		// TODO
		.success([])
	}

	public func loadRaindrops(filteredByFilterWith id: Dewdrop.Filter.ID, count: Int) async -> Result<[Raindrop]> {
		let list: Result<[RaindropListFields]>
		let filterName = Filter.ID.Name(id: id)

		switch filterName {
		case .highlighted:
			let highlights: [HighlightListFields] = await database.listHighlights().value
			let highlightedRaindropIDs = Set(highlights.map(\.raindropID))
			list = await database.fetch(where: highlightedRaindropIDs.contains(\.id))
		default:
			let query = Filter.query(for: id)
			list = await database.listRaindrops(searchingFor: query)
		}

		return await list.map { raindrops in
			raindrops.map(Raindrop.init)
		}
	}

	public func save(_ raindrops: [Raindrop], inCollectionWith id: Collection.ID) async -> Result<[Raindrop.ID]> {
		let existingIDs = await loadRaindrops(inCollectionWith: id, count: raindrops.count).value.map(\.id)
		return await save(raindrops, replacingRaindropsWith: existingIDs)
	}

	public func save(_ raindrops: [Raindrop], filteredByFilterWith id: Dewdrop.Filter.ID) async -> Result<[Raindrop.ID]> {
		let existingIDs = await loadRaindrops(filteredByFilterWith: id, count: raindrops.count).value.map(\.id)
		return await save(raindrops, replacingRaindropsWith: existingIDs)
	}
}

// MARK: -
private extension Database {
	func save(_ raindrops: [Raindrop], replacingRaindropsWith existingIDs: [Raindrop.ID]) async -> Result<[Raindrop.ID]> {
		await database.delete(Raindrop.self, with: existingIDs).flatMap { _ in
			await database.delete(Raindrop.self, with: raindrops.map(\.id))
		}.flatMap { _ in
			await database.insert(raindrops)
		}.map { _ in
			await raindrops.concurrentMap { raindrop in
				await save(raindrop.highlights ?? [])
			}
		}.map { _ in
			raindrops.map(\.id)
		}
	}
}
