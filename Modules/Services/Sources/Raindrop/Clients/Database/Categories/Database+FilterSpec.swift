// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import protocol RaindropService.FilterSpec
import protocol RaindropService.CollectionSpec
import protocol DewdropService.RaindropFields
import protocol Ergo.WorkerOutput

extension Database: FilterSpec {
	public func loadFilters() async -> Result<[Filter]> {
		await database.listFilters().map { filters in
			await filters.concurrentMap { filter in
				.init(
					fields: filter
				)
			}
		}
	}

	public func save(_ filters: [Filter]) async -> Result<[Filter.ID]> {
		guard !filters.isEmpty else { return .success([]) }

		return await database.delete(Filter.self, with: filters.map(\.id)).flatMap { _ in
			await database.insert(filters)
		}.map { _ in
			filters.map(\.id)
		}
	}
}
