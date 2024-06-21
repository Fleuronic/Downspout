// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import protocol Ergo.WorkerOutput

public protocol CollectionSpec: Sendable where CollectionLoadingResult.Failure: Equatable & Sendable {
	associatedtype CollectionLoadingResult: WorkerOutput<[Collection]>

	func loadSystemCollections() async -> CollectionLoadingResult
}
