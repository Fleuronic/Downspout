// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import struct DewdropAPI.API
import protocol Ergo.WorkerOutput
import protocol RaindropService.FilterSpec

extension API: FilterSpec {
	public func loadFilters() async -> Filter.LoadingResult {
		await api.listFilters().map { filters in
			filters.filters.map { filter in
				.init(
					id: filter.id,
					count: filter.count
				)
			} + [
				(.favorited, filters.favorited),
				(.highlighted, filters.highlighted),
				(.duplicate, filters.duplicate),
				(.untagged, filters.untagged),
				(.broken, filters.broken)
			].compactMap { id, filter in
				filter.map { (.init(id), $0.count) }
			}.map { id, count in
				.init(
					id: id,
					count: count
				)
			}
		}
	}
}



// MARK: -
public extension Filter {
	typealias LoadingResult = API.Result<[Filter]>
}
