// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Highlight
import protocol RaindropService.HighlightSpec
import protocol Ergo.WorkerOutput

extension Database: HighlightSpec {
	public func save(_ highlights: [Highlight]) async -> Result<[Highlight.ID]> {
		guard !highlights.isEmpty else { return .success([]) }

		let ids = highlights.map(\.id)

		return await database.delete(Highlight.self, with: ids).flatMap { _ in
			await database.insert(highlights)
		}
	}
}
