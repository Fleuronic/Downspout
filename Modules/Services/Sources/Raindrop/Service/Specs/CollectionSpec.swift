// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import protocol Ergo.WorkerOutput

public protocol CollectionSpec {
	associatedtype CollectionLoadingResult: WorkerOutput

	func loadSystemCollections() async -> CollectionLoadingResult
}
