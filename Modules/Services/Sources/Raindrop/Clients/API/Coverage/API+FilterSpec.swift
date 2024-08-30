// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import struct DewdropAPI.API
import protocol Catenary.API
import protocol RaindropService.FilterSpec
import protocol Ergo.WorkerOutput

extension API: FilterSpec {
	public func loadFilters() async -> Self.Result<[Raindrop.Filter]> {
		await api.listFilters().map { filters in
			let topFilters = [
				(Filter.ID.Name.favorited, filters.favorited),
				(.highlighted, filters.highlighted)
			].enumerated().compactMap { index, entry in
				Filter(
					idName: entry.0,
					filter: entry.1,
					sortIndex: index
				)
			}

			let middleFilters = filters.typeFilters.enumerated().map { index, fields in
				Filter(
					fields: fields,
					sortIndex: index + topFilters.count
				)
			}

			let bottomFilters = [
				(Filter.ID.Name.duplicate, filters.duplicate),
				(.untagged, filters.untagged),
				(.broken, filters.broken)
			].enumerated().compactMap { index, entry in
				Filter(
					idName: entry.0,
					filter: entry.1,
					sortIndex: index + topFilters.count + middleFilters.count
				)
			}

			return topFilters + middleFilters + bottomFilters
		}
	}
}
