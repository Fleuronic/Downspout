// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Tag
import protocol Ergo.WorkerOutput

public protocol TagSpec: Sendable where TagLoadResult.Failure: Equatable & Sendable {
	associatedtype TagLoadResult: WorkerOutput<[Tag]>
	associatedtype TagSaveResult: WorkerOutput<[Tag.ID]>

	func loadTags() async -> TagLoadResult
	func save(_ tags: [Tag]) async -> TagSaveResult
}
