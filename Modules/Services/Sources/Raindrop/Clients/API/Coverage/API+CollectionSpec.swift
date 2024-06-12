// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import struct DewdropAPI.API
import protocol Ergo.WorkerOutput
import protocol RaindropService.CollectionSpec

extension API: CollectionSpec {
	public func loadSystemCollections() async -> Collection.LoadingResult {
		await api.listSystemCollections().map { collections in
			collections.compactMap { collection in
				.init(
					id: collection.id,
					count: collection.count
				)
			}
		}
	}
}

// MARK: -
public extension Collection {
	typealias LoadingResult = API.Result<[Collection]>
}
