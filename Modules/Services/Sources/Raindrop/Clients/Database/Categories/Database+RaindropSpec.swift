// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Raindrop.Tag
import struct Raindrop.Tagging
import struct Dewdrop.Filter
import struct DewdropService.Tagging
import protocol RaindropService.RaindropSpec
import protocol DewdropService.RaindropFields
import protocol Ergo.WorkerOutput

extension Database: RaindropSpec {
	public func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) async -> Result<[Raindrop]> {
		await database.listRaindrops(inCollectionWith: id).map { raindrops in
			raindrops.map(Raindrop.init)
		}
	}

	public func loadRaindrops(filteredByFilterWith id: Dewdrop.Filter.ID, count: Int) async -> Result<[Raindrop]> {
		let list: Result<[RaindropListFields]>
		let filterName = Filter.ID.Name(id: id)

		switch filterName {
		case .highlighted:
			let highlights: [HighlightListFields] = await database.listHighlights().value
			let highlightedRaindropIDs = Set(highlights.map(\.raindropID))
			list = await database.fetch(where: highlightedRaindropIDs.contains(\.id))
		case .untagged:
			let taggings: [TaggingListFields] = await database.fetch().value
			let taggingRaindropIDs = Set(taggings.map(\.raindropID))
			list = await database.fetch(where: !taggingRaindropIDs.contains(\.id))
		default:
			let query = Filter.query(for: id)
			list = await database.listRaindrops(searchingFor: query)
		}

		#if compiler(>=6.0)
		return await list.map { raindrops in
			raindrops.map(Raindrop.init)
		}
		#else
		return list.map { raindrops in
			raindrops.map(Raindrop.init)
		}
		#endif
	}

	public func loadRaindrops(taggedWithTagNamed name: String, count: Int) async -> Result<[Raindrop]> {
		let taggings: [TaggingListFields] = await database.fetch(where: \.tagName == name).value
		let raindropIDs = taggings.map(\.raindropID)
		return await database.fetch(where: raindropIDs.contains(\.id)).map { raindrops in
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

	public func save(_ raindrops: [Raindrop], taggedWithTagNamed name: String) async -> Result<[Raindrop.ID]> {
		let existingIDs = await loadRaindrops(taggedWithTagNamed: name,  count: raindrops.count).value.map(\.id)
		return await save(raindrops, replacingRaindropsWith: existingIDs)
	}
}

// MARK: -
private extension Database {
	func save(_ raindrops: [Raindrop], replacingRaindropsWith existingIDs: [Raindrop.ID]) async -> Result<[Raindrop.ID]> {
		let ids = raindrops.map(\.id)
		return await database.delete(Raindrop.self, with: existingIDs).map { _ in
			await database.delete(Raindrop.self, with: ids)
		}.map { _ in
			await database.insert(raindrops)
		}.map { _ in
			let taggings: [TaggingListFields] = await database.fetch(where: ids.contains(\.raindrop.id)).value
			return await database.delete(Tagging.self, with: taggings.map(\.id))
		}.map { _ in
			let taggings = raindrops.flatMap { $0.taggings ?? [] }
			return await database.insert(taggings)
		}.map { _ in
			let highlights = raindrops.flatMap { $0.highlights ?? [] }
			return await save(highlights)
		}.map { _ in
			raindrops.map(\.id)
		}
	}
}
