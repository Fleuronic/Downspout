// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Raindrop.Tag
import struct Raindrop.Tagging
import struct Dewdrop.Filter
import struct DewdropService.Tagging
import struct Foundation.URL
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
		let list: Result<[RaindropListFields]> = await database.fetch(where: raindropIDs.contains(\.id) && \.collection.id != .trash)

		return await list.map { raindrops in
			raindrops.map(Raindrop.init)
		}
	}
}
