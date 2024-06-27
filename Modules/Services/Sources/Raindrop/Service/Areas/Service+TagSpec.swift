// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Tag
import protocol Ergo.WorkerOutput

extension Service: TagSpec where
	API: TagSpec,
	API.TagLoadResult == APIResult<[Tag]> {
	public func loadTags() async -> API.TagLoadResult {
		await api.loadTags()
	}
}
