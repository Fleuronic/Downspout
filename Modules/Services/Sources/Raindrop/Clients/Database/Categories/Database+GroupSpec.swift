// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import struct Raindrop.Collection
import struct Foundation.KeyPathComparator
import protocol RaindropService.GroupSpec
import protocol RaindropService.CollectionSpec
import protocol DewdropService.RaindropFields
import protocol Ergo.WorkerOutput

extension Database: GroupSpec {
	public func loadGroups() async -> Self.Result<[Group]> {
		await database.listGroups().map { fields in
			fields.map(Group.init)
		}
	}

	public func save(_ groups: [Group]) async -> Self.Result<[Group.ID]> {
		await database.delete(Group.self, with: groups.map(\.id)).flatMap { _ in
			await database.insert(groups)
		}.map { _ in
			await groups.map { group in
				await save(group.collections)
			}
		}.map { _ in
			groups.map(\.id)
		}
	}
}
