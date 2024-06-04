// Copyright © Fleuronic LLC. All rights reserved.

import Dispatch

import struct Raindrop.Group
import struct Foundation.TimeInterval
import protocol RaindropService.LoadingSpec

struct MockRaindropAPI: LoadingSpec {
	let duration: TimeInterval
	let result: () -> Group.LoadingResult

	init(
		duration: TimeInterval,
		result: @autoclosure @escaping () -> Group.LoadingResult
	) {
		self.duration = duration
		self.result = result
	}

	func loadGroups() async -> Group.LoadingResult {
		try! await Task.sleep(nanoseconds: UInt64(duration * TimeInterval(NSEC_PER_SEC)))
		return result()
	}
}
