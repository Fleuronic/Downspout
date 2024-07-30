// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import struct DewdropAPI.API
import protocol Catenary.API
import protocol RaindropService.FilterSpec
import protocol Ergo.WorkerOutput

extension API: FilterSpec {
	public func loadFilters() async -> Self.Result<[Raindrop.Filter]> {
		await api.listFilters().map { filters in
			[
				(.favorited, filters.favorited),
				(.highlighted, filters.highlighted),
			].compactMap(Filter.init) + filters.filters.map(Filter.init) + [
				(.duplicate, filters.duplicate),
				(.untagged, filters.untagged),
				(.broken, filters.broken)
			].compactMap(Filter.init)
		}
	}

	public func save(_ filters: [Filter]) -> Self.Result<[Filter.ID]> {
		.success(filters.map(\.id))
	}
}
