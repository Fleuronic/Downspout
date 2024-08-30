// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Tag
import protocol Ergo.WorkerOutput

public protocol TagSpec: Sendable where TagLoadResult.Failure: Equatable & Sendable {
	associatedtype TagLoadResult: WorkerOutput<[Tag]>

	func loadTags() async -> TagLoadResult
}
