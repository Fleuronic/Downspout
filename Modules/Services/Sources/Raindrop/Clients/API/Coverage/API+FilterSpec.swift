// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import struct DewdropAPI.API
import protocol Ergo.WorkerOutput
import protocol RaindropService.FilterSpec

extension API: FilterSpec {
	public func loadFilters() async -> Filter.LoadingResult {
		await api.listFilters().map { filters in
			[]
		}
	}
}

// MARK: -
public extension Filter {
	typealias LoadingResult = API.Result<[Filter]>
}
