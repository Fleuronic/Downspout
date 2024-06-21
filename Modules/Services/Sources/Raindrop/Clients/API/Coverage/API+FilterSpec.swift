// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import struct Dewdrop.Filter
import struct DewdropAPI.API
import struct DewdropService.FilterCountFields
import protocol Catena.API
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
}

// MARK: -
private extension Raindrop.Filter {
	init(fields: FilterCountFields) {
		self.init(
			id: fields.id,
			count: fields.count
		)
	}

	init?(
		idName: Raindrop.Filter.ID.Name,
		filter: Dewdrop.Filter?
	) {
		guard let filter else { return nil }

		self.init(
			id: .init(idName),
			count: filter.count
		)
	}
}
