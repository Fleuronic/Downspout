// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Raindrop.Tag
import protocol Ergo.WorkerOutput

public protocol RaindropSpec: Sendable where RaindropLoadingResult.Failure: Equatable & Sendable {
	associatedtype RaindropLoadingResult: WorkerOutput<[Raindrop]>

	func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) async -> RaindropLoadingResult
	func loadRaindrops(taggedWithTagNamed name: String, count: Int) async -> RaindropLoadingResult
	func loadRaindrops(filteredByFilterWith id: Filter.ID, count: Int) async -> RaindropLoadingResult
}
