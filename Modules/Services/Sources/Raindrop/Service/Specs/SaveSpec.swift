// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Raindrop.Tag
import struct Raindrop.Raindrop
import struct Foundation.URL
import protocol Ergo.WorkerOutput

public protocol SaveSpec: Sendable {
	associatedtype GroupSaveResult: WorkerOutput<[Group.ID]>
	associatedtype CollectionSaveResult: WorkerOutput<[Collection.ID]>
	associatedtype FilterSaveResult: WorkerOutput<[Filter.ID]>
	associatedtype TagSaveResult: WorkerOutput<[Tag.ID]>
	associatedtype RaindropSaveResult: WorkerOutput<[Raindrop.ID]>

	func save(_ groups: [Group]) async -> GroupSaveResult
	func save(_ collections: [Collection]) async -> CollectionSaveResult
	func save(_ filters: [Filter]) async -> FilterSaveResult
	func save(_ tags: [Tag]) async -> TagSaveResult
	func save(_ raindrops: [Raindrop], inCollectionWith id: Collection.ID) async -> RaindropSaveResult
	func save(_ raindrops: [Raindrop], taggedWithTagNamed name: String) async -> RaindropSaveResult
	func save(_ raindrops: [Raindrop], filteredByFilterWith id: Filter.ID) async -> RaindropSaveResult

	func saveAddedRaindrop(_ raindrop: Raindrop) async -> RaindropSaveResult
}
