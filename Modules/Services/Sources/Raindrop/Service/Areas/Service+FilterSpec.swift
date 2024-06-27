// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import protocol Ergo.WorkerOutput

extension Service: FilterSpec where
	API: FilterSpec,
	API.FilterLoadResult == APIResult<[Filter]> {
	public func loadFilters() async -> API.FilterLoadResult {
		await api.loadFilters()
	}
}
