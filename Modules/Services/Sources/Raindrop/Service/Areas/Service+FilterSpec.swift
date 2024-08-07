// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import protocol Ergo.WorkerOutput

extension Service: FilterSpec where
	API: FilterSpec,
	API.FilterLoadResult == APIResult<[Filter]>,
	Database: FilterSpec,
	Database.FilterLoadResult == DatabaseResult<[Filter]>,
	Database.FilterSaveResult == DatabaseResult<[Filter.ID]> {
	public func loadFilters() async -> Stream<API.FilterLoadResult> {
		await load { api in
			await api.loadFilters().map { filters in
				await self.save(filters).map { _ in filters }.value
			}
		} databaseResult: { database in
			await database.loadFilters()
		}
	}

	public func save(_ filters: [Filter]) async -> Database.FilterSaveResult {
		await database.save(filters)
	}
}
