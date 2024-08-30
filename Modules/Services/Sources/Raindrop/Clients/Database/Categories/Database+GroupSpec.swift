// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import struct Raindrop.Collection
import struct Raindrop.Raindrop
import protocol RaindropService.GroupSpec
import protocol Ergo.WorkerOutput

extension Database: GroupSpec {
	public func loadGroups() async -> Result<[Group]> {
		await database.listGroups().map { groups in
			await groups.concurrentMap { group in
				await .init(
					fields: group,
					collections: collections(fields: group.collections)
				)
			}
		}
	}
}

// MARK: -
private extension Database {
	func collections(fields: [CollectionListFields]) async -> [Collection] {
		await fields.concurrentMap { fields in
			await collection(
				fields: fields,
				childCollectionListFields: await database.listChildCollections().value
			)
		}
	}

	func collection(
		fields: CollectionListFields,
		childCollectionListFields: [ChildCollectionListFields]
	) async -> Collection {
		await .init(
			id: fields.id,
			parentID: nil,
			title: fields.title,
			count: fields.count,
			isShared: fields.isShared,
			sortIndex: fields.sortIndex,
			groupID: nil,
			collections: childCollectionListFields.filter { $0.parentID == fields.id }.concurrentMap { fields in
				await collection(
					fields: fields,
					childCollectionListFields: childCollectionListFields
				)
			},
			raindrops: database.listRaindrops(inCollectionWith: fields.id).value.map(Raindrop.init)
		)
	}

	func collection(
		fields: ChildCollectionListFields,
		childCollectionListFields: [ChildCollectionListFields]
	) async -> Collection {
		await .init(
			id: fields.id,
			parentID: fields.parentID,
			title: fields.title,
			count: fields.count,
			isShared: fields.isShared,
			sortIndex: fields.sortIndex,
			groupID: nil,
			collections: childCollectionListFields.filter { $0.parentID == fields.id }.concurrentMap { fields in
				await collection(
					fields: fields,
					childCollectionListFields: childCollectionListFields
				)
			},
			raindrops: database.listRaindrops(inCollectionWith: fields.id).value.map(Raindrop.init)
		)
	}
}
