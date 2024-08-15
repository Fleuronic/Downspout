// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Highlight
import protocol Ergo.WorkerOutput

public protocol HighlightSpec: Sendable {
	associatedtype HighlightSaveResult: WorkerOutput<[Highlight.ID]>

	func save(_ highlights: [Highlight]) async -> HighlightSaveResult
}
