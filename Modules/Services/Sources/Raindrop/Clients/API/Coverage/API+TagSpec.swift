// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Tag
import struct DewdropAPI.API
import protocol Catena.API
import protocol Ergo.WorkerOutput
import protocol RaindropService.TagSpec

extension API: TagSpec {
	public func loadTags() async -> Self.Result<[Tag]> {
		await api.listTags().map { tags in
			tags.map { tag in
				.init(
					name: tag.id.rawValue,
					raindropCount: tag.count
				)
			}
		}
	}
}
