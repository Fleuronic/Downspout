// Copyright © Fleuronic LLC. All rights reserved.

import protocol Ergo.WorkerOutput

public protocol TagSpec {
	associatedtype TagLoadingResult: WorkerOutput

	func loadTags() async -> TagLoadingResult
}
