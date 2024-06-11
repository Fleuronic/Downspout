// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Tag
import struct DewdropAPI.API
import struct DewdropService.ImportFolderFields
import protocol RaindropService.TagSpec

extension API: TagSpec {
	public func loadTags() async -> Tag.LoadingResult {
		await api.listTags().map { tags in
			tags.map { tag in
				.init(
					name: tag.id.rawValue,
					raindropCount: tag.count,
					loadedRaindrops: []
				)
			}
		}
	}
}

// MARK: -
public extension Tag {
	typealias LoadingResult = API.Result<[Tag]>
}
