// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import protocol Ergo.WorkerOutput

extension Service: GroupSpec where
	API: GroupSpec,
	API.GroupLoadResult == APIResult<[Group]>,
	Database: GroupSpec,
	Database.GroupLoadResult == DatabaseResult<[Group]>,
	Database.GroupSaveResult == DatabaseResult<[Group.ID]> {
	public func loadGroups() async -> Stream<API.GroupLoadResult> {
		await load { api in
			await api.loadGroups().map { groups in
				await self.save(groups).map { _ in groups }.value
			}
		} databaseResult: { database in
			await database.loadGroups()
		}
	}

	public func save(_ groups: [Group]) async -> Database.GroupSaveResult {
		await database.save(groups)
	}
}
