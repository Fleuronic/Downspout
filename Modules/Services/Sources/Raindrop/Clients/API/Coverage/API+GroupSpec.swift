// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import struct Raindrop.Collection
import struct Dewdrop.Collection
import struct DewdropAPI.API
import protocol Catenary.API
import protocol Ergo.WorkerOutput
import protocol RaindropService.GroupSpec

extension API: GroupSpec {
	public func loadGroups() async -> Self.Result<[Group]> {
		async let userDetailsResult = api.fetchUserAuthenticatedDetails()
		async let rootCollectionsResult = api.listRootCollections()
		async let childCollectionsResult = api.listChildCollections()

		let rootCollections: [Dewdrop.Collection.ID: CollectionListFields]
		switch await rootCollectionsResult {
		case let .success(collections):
			rootCollections = .init(
				uniqueKeysWithValues: collections.map { ($0.id, $0) }
			)
		case let .failure(error):
			return .failure(error)
		}
		
		let childCollections: [CollectionListFields]
		switch await childCollectionsResult {
		case let .success(collections):
			childCollections = collections
		case let .failure(error):
			return .failure(error)
		}
		
		return await userDetailsResult.map { details in
			details.groups.enumerated().map { index, group in
				.init(
					groupDetailsFields: group,
					sortIndex: index,
					rootCollectionListFields: rootCollections,
					childCollectionListFields: childCollections
				)
			}
		}
	}
}
