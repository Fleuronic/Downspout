// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import protocol Ergo.WorkerOutput

public protocol FilterSpec {
	associatedtype FilterLoadingResult: WorkerOutput

	func loadFilters() async -> FilterLoadingResult
}
