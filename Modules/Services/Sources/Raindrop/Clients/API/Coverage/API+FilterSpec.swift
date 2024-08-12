// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
//import struct Dewdrop.Filter
import struct DewdropAPI.API
import protocol Catenary.API
import protocol RaindropService.FilterSpec
import protocol Ergo.WorkerOutput

extension API: FilterSpec {
	public func loadFilters() async -> Self.Result<[Raindrop.Filter]> {
		await api.listFilters().map { filters in
			let typeFilterIndex = 2
			let typeFilters = filters.typeFilters.enumerated().map { index, fields in
				Filter(
					fields: fields,
					sortIndex: index + typeFilterIndex
				)
			}

			let namedFilters = [
				(Filter.ID.Name.favorited, filters.favorited),
				(.highlighted, filters.highlighted),
				(.duplicate, filters.duplicate),
				(.untagged, filters.untagged),
				(.broken, filters.broken)
			].enumerated().compactMap { index, entry in
				Filter(
					idName: entry.0,
					filter: entry.1,
					sortIndex: index < typeFilterIndex ? index : index + typeFilters.count - 1
				)
			}

			return namedFilters[0..<typeFilterIndex] + typeFilters + namedFilters[typeFilterIndex...]
		}
	}

	public func save(_ filters: [Filter]) -> Self.Result<[Filter.ID]> {
		.success(filters.map(\.id))
	}
}
