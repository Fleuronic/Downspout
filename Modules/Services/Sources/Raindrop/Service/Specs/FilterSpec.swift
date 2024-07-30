// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import protocol Ergo.WorkerOutput

public protocol FilterSpec: Sendable where FilterLoadResult.Failure: Equatable & Sendable { // TODO
	associatedtype FilterLoadResult: WorkerOutput<[Filter]>
	associatedtype FilterSaveResult: WorkerOutput<[Filter.ID]>

	func loadFilters() async -> FilterLoadResult

	func save(_ filters: [Filter]) async -> FilterSaveResult
}
