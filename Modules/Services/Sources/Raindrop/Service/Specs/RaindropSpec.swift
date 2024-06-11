// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import protocol Ergo.WorkerOutput

public protocol RaindropSpec {
	associatedtype RaindropLoadingResult: WorkerOutput

	func loadRaindrops(inCollectionWith id: Collection.ID) async -> RaindropLoadingResult
}
