// Copyright © Fleuronic LLC. All rights reserved.

import Dispatch

import struct Raindrop.Filter
import struct Foundation.TimeInterval
import protocol RaindropService.FilterSpec

struct MockRaindropAPI: FilterSpec {
	let duration: TimeInterval
	let result: () -> Filter.LoadingResult

	init(
		duration: TimeInterval,
		result: @autoclosure @escaping () -> Filter.LoadingResult
	) {
		self.duration = duration
		self.result = result
	}

	func loadFilters() async -> Filter.LoadingResult {
		try! await Task.sleep(nanoseconds: UInt64(duration * TimeInterval(NSEC_PER_SEC)))
		return result()
	}
}
