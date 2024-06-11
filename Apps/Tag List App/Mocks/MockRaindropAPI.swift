// Copyright © Fleuronic LLC. All rights reserved.

import Dispatch

import struct Raindrop.Tag
import struct Foundation.TimeInterval
import protocol RaindropService.TagSpec

struct MockRaindropAPI: TagSpec {
	let duration: TimeInterval
	let result: () -> Tag.LoadingResult

	init(
		duration: TimeInterval,
		result: @autoclosure @escaping () -> Tag.LoadingResult
	) {
		self.duration = duration
		self.result = result
	}

	func loadTags() async -> Tag.LoadingResult {
		try! await Task.sleep(nanoseconds: UInt64(duration * TimeInterval(NSEC_PER_SEC)))
		return result()
	}
}
