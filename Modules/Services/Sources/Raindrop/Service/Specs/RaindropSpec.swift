// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Raindrop.Tag
import protocol Ergo.WorkerOutput

public protocol RaindropSpec: Sendable where RaindropLoadResult.Failure: Equatable & Sendable {
	associatedtype RaindropLoadResult: WorkerOutput<[Raindrop]>
	associatedtype RaindropSaveResult: WorkerOutput<[Raindrop.ID]>

	func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) async -> RaindropLoadResult
	func loadRaindrops(taggedWithTagNamed name: String, count: Int) async -> RaindropLoadResult
	func loadRaindrops(filteredByFilterWith id: Filter.ID, count: Int) async -> RaindropLoadResult

	func save(_ raindrops: [Raindrop], inCollectionWith id: Collection.ID) async -> RaindropSaveResult
}
