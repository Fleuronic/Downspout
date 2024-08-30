
// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB

import struct Raindrop.Group
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Raindrop.Tag
import struct Raindrop.Tagging
import struct Raindrop.Raindrop
import struct DewdropService.Tagging
import struct Foundation.URL
import protocol RaindropService.SaveSpec
import protocol DewdropService.RaindropFields
import protocol Ergo.WorkerOutput

extension Database: SaveSpec {
	public func save(_ groups: [Group]) async -> Result<[Group.ID]> {
		guard !groups.isEmpty else { return .success([]) }

		let rootList = await database.listRootCollections().value
		let childList = await database.listChildCollections().value
		let ids = rootList.map(\.id) + childList.map(\.id)

		return await database.delete(Collection.self, with: ids).flatMap { _ in
			await database.delete(Group.self, with: groups.map(\.id))
		}.map { _ in
			await database.insert(groups)
		}.map { _ in
			await groups.concurrentMap { group in
				await save(group.collections)
			}
		}.map { _ in
			groups.map(\.id)
		}
	}

	public func save(_ collections: [Collection]) async -> Result<[Collection.ID]> {
		guard !collections.isEmpty else { return .success([]) }

		var ids = collections.map(\.id)
		var raindropIDs: [Raindrop.ID] = []
		if ids.contains(.all) && !ids.contains(.trash) {
			ids += [.trash]
			raindropIDs = await database.listRaindrops(inCollectionWith: .trash).value.map(\.id)
		}

		return await database.delete(Raindrop.self, with: raindropIDs).map { _ in
			await database.delete(Collection.self, with: ids)
		}.map { _ in
			await database.insert(collections)
		}.map { _ in
			await collections.concurrentMap { collection in
				await save(collection.collections)
			}.flatMap(\.value)
		}
	}

	public func save(_ filters: [Filter]) async -> Result<[Filter.ID]> {
		guard !filters.isEmpty else { return .success([]) }

		let ids = filters.map(\.id)
		return await database.delete(Filter.self, with: ids).flatMap { _ in
			await database.insert(filters)
		}
	}

	public func save(_ tags: [Tag]) async -> Result<[Tag.ID]> {
		guard !tags.isEmpty else { return .success([]) }

		return await database.delete(Tag.self).flatMap { _ in
			await database.insert(tags)
		}
	}

	public func save(_ raindrops: [Raindrop], inCollectionWith id: Collection.ID) async -> Result<[Raindrop.ID]> {
		let existingIDs = await loadRaindrops(inCollectionWith: id, count: raindrops.count).value.map(\.id)
		return await save(raindrops, replacingRaindropsWith: existingIDs)
	}

	public func save(_ raindrops: [Raindrop], filteredByFilterWith id: Filter.ID) async -> Result<[Raindrop.ID]> {
		let existingIDs = await loadRaindrops(filteredByFilterWith: id, count: raindrops.count).value.map(\.id)
		return await save(raindrops, replacingRaindropsWith: existingIDs)
	}

	public func save(_ raindrops: [Raindrop], taggedWithTagNamed name: String) async -> Result<[Raindrop.ID]> {
		let existingIDs = await loadRaindrops(taggedWithTagNamed: name,  count: raindrops.count).value.map(\.id)
		return await save(raindrops, replacingRaindropsWith: existingIDs)
	}

	public func saveAddedRaindrop(_ raindrop: Raindrop) async -> Result<[Raindrop.ID]> {
		await database.insert(raindrop).map { _ in
			let ids: [Collection.ID] = [.all, .unsorted]
			let list: Result<[SystemCollectionListFields]> = await database.fetch(where: ids.contains(\.id))
			let collections = list.value.map { collection in
				Collection(
					fields: collection,
					raindrops: nil,
					increment: 1
				)
			}
			
			return await database.delete(Collection.self, with: ids).flatMap { _ in
				await database.insert(collections)
			}
		}.map { _ in [raindrop.id] }
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
