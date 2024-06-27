// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import struct DewdropAPI.API
import struct Foundation.KeyPathComparator
import protocol Catenary.API
import protocol Ergo.WorkerOutput
import protocol RaindropService.CollectionSpec

extension API: CollectionSpec {
	public func loadSystemCollections() async -> Self.Result<[Collection]> {
		await api.listSystemCollections().map { collections in
			collections.compactMap { collection in
				.init(
					id: collection.id,
					count: collection.count
				)
			}
		}
	}

	public func save(_ collections: [Collection]) -> Self.Result<[Collection.ID]> {
		.success(collections.map(\.id))
	}
}
