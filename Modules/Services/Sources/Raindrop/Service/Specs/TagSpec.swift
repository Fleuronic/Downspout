// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Tag
import protocol Ergo.WorkerOutput

public protocol TagSpec: Sendable where TagLoadingResult.Failure: Equatable & Sendable {
	associatedtype TagLoadingResult: WorkerOutput<[Tag]>

	func loadTags() async -> TagLoadingResult
}
