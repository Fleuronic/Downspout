// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Tag
import protocol RaindropService.TagSpec
import protocol Ergo.WorkerOutput

extension Database: TagSpec {
	public func loadTags() async -> Result<[Tag]> {
		await database.listTags().map { tags in
			await tags.concurrentMap { tag in
				.init(
					fields: tag,
					raindrops: await loadRaindrops(taggedWithTagNamed: tag.name, count: tag.count).value
				)
			}
		}
	}

	public func save(_ tags: [Tag]) async -> Result<[Tag.ID]> {
		guard !tags.isEmpty else { return .success([]) }

		let ids = tags.map(\.id)
		return await database.delete(Tag.self, with: ids).flatMap { _ in
			await database.insert(tags)
		}
	}
}
