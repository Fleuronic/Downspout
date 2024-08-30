// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Tag
import protocol Ergo.WorkerOutput

extension Service: TagSpec where
	API: TagSpec,
	API.TagLoadResult == APIResult<[Tag]>,
	Database: TagSpec,
	Database.TagLoadResult == DatabaseResult<[Tag]>,
	Database.TagSaveResult == DatabaseResult<[Tag.ID]> {
	public func loadTags() async -> Stream<API.TagLoadResult> {
		await load { api, database in
			await api.loadTags().map { tags in
				await database.save(tags).map { _ in tags }.value
			}
		} databaseResult: { database in
			await database.loadTags()
		}
	}
}
