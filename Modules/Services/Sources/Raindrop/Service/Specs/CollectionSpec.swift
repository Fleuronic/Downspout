// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import protocol Ergo.WorkerOutput

public protocol CollectionSpec: Sendable where CollectionLoadResult.Failure: Equatable & Sendable {
	associatedtype CollectionLoadResult: WorkerOutput<[Collection]>

	func loadSystemCollections() async -> CollectionLoadResult
}
