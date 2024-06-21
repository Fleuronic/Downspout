// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import protocol Ergo.WorkerOutput

public protocol FilterSpec: Sendable  where FilterLoadingResult.Failure: Equatable & Sendable {
	associatedtype FilterLoadingResult: WorkerOutput<[Filter]>

	func loadFilters() async -> FilterLoadingResult
}
