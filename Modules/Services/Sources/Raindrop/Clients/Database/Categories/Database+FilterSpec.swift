// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import struct Raindrop.Raindrop
import protocol RaindropService.FilterSpec
import protocol RaindropService.CollectionSpec
import protocol DewdropService.RaindropFields
import protocol Ergo.WorkerOutput

extension Database: FilterSpec {
	public func loadFilters() async -> Result<[Filter]> {
		await database.listFilters().map { filters in
			await filters.enumerated().concurrentMap { index, filter in
				let query = Filter.query(for: filter.id)
				return .init(
					fields: filter,
					sortIndex: index,
					raindrops: await database.listRaindrops(searchingFor: query).value.map(Raindrop.init)
				)
			}
		}
	}

	public func save(_ filters: [Filter]) async -> Result<[Filter.ID]> {
		guard !filters.isEmpty else { return .success([]) }

		let ids = filters.map(\.id)
		return await database.delete(Filter.self, with: ids).flatMap { _ in
			await database.insert(filters)
		}.map { _ in
			filters.map(\.id)
		}
	}
}
