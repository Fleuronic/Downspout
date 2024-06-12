// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import struct Raindrop.Tag
import protocol Ergo.WorkerOutput

public protocol RaindropSpec {
	associatedtype RaindropLoadingResult: WorkerOutput

	func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) async -> RaindropLoadingResult
	func loadRaindrops(taggedByTagNamed name: String, count: Int) async -> RaindropLoadingResult
}
