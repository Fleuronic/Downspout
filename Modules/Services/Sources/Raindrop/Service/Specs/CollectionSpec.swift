// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import protocol Ergo.WorkerOutput

public protocol CollectionSpec: Sendable where CollectionLoadResult.Failure: Equatable & Sendable {
	associatedtype CollectionLoadResult: WorkerOutput<[Collection]>
	associatedtype CollectionSaveResult: WorkerOutput<[Collection.ID]>

	func loadSystemCollections() async -> CollectionLoadResult
	func save(_ collections: [Collection]) async -> CollectionSaveResult
}
