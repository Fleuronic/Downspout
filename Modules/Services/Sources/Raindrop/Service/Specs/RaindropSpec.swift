// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Raindrop.Tag
import struct Foundation.URL
import protocol Ergo.WorkerOutput

public protocol RaindropSpec: Sendable where
	RaindropLoadResult.Failure: Equatable & Sendable {
	associatedtype RaindropLoadResult: WorkerOutput<[Raindrop]>

	func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) async -> RaindropLoadResult
	func loadRaindrops(filteredByFilterWith id: Filter.ID, count: Int) async -> RaindropLoadResult
	func loadRaindrops(taggedWithTagNamed name: String, count: Int) async -> RaindropLoadResult
}
