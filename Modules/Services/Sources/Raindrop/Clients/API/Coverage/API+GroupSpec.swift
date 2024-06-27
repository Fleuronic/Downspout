// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import struct Raindrop.Collection
import struct Dewdrop.Collection
import struct DewdropAPI.API
import struct DewdropService.UserAuthenticatedDetailsFields
import struct DewdropService.CollectionDetailsFields
import protocol Catenary.API
import protocol Ergo.WorkerOutput
import protocol RaindropService.GroupSpec

extension API: GroupSpec {
	public func loadGroups() async -> Self.Result<[Group]> {
		let userDetailsResult = await api.fetchUserAuthenticatedDetails()
		let rootCollectionsResult = await api.listRootCollections()
		let childCollectionsResult = await api.listChildCollections()

		let rootCollections: [CollectionDetailsFields]
		switch rootCollectionsResult {
		case let .success(collections): rootCollections = collections
		case let .failure(error): return .failure(error)
		}
		
		let childCollections: [CollectionDetailsFields]
		switch childCollectionsResult {
		case let .success(collections): childCollections = collections
		case let .failure(error): return .failure(error)
		}
		
		return userDetailsResult.map { details in
			let rootCollections = Dictionary(uniqueKeysWithValues: rootCollections.map { ($0.id, $0) })
			return details.groups.map { group in
				.init(
					title: group.title,
					collections: group.collections.map(\.id).map { id in
						let collection = rootCollections[id]!
						return .init(
							id: collection.id,
							title: collection.title,
							count: collection.count,
							isShared: collection.isShared,
							collections: children(
								id: collection.id,
								childCollections: childCollections
							)
						)
					}
				)
			}
		}
	}
}

// MARK: -
private extension API {
	func children(
		id: Dewdrop.Collection.ID,
		childCollections: [CollectionDetailsFields]
	) -> [Raindrop.Collection] {
		childCollections.filter { $0.parent?.id == id }.map { collection in
			.init(
				id: collection.id,
				title: collection.title,
				count: collection.count,
				isShared: collection.isShared,
				collections: children(
					id: collection.id,
					childCollections: childCollections
				)
			)
		}
	}
}
