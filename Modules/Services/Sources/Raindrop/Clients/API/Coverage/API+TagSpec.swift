// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Tag
import struct DewdropAPI.API
import protocol Catenary.API
import protocol Ergo.WorkerOutput
import protocol RaindropService.TagSpec

extension API: TagSpec {
	public func loadTags() async -> Self.Result<[Tag]> {
		await api.listTags().map { tags in
			tags.map(Tag.init)
		}
	}

	public func save(_ tags: [Tag]) -> Self.Result<[Tag.ID]> {
		.success(tags.map(\.id))
	}
}
