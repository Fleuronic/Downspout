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
				.init(
					fields: filter,
					sortIndex: index,
					raindrops: await loadRaindrops(filteredByFilterWith: filter.id, count: filter.count).value
				)
			}
		}
	}
}
