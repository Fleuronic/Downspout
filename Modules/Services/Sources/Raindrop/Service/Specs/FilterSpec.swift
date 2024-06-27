// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import protocol Ergo.WorkerOutput

public protocol FilterSpec: Sendable  where FilterLoadResult.Failure: Equatable & Sendable {
	associatedtype FilterLoadResult: WorkerOutput<[Filter]>

	func loadFilters() async -> FilterLoadResult
}
