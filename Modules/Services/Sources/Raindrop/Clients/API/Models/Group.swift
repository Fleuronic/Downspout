// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import struct Raindrop.Collection
import struct Dewdrop.Collection
import struct DewdropService.IdentifiedCollection
import struct DewdropService.GroupDetailsFields
import struct DewdropService.CollectionDetailsFields

extension Group {
	init(
		groupDetailsFields: GroupDetailsFields,
		rootCollectionDetailsFields: [Dewdrop.Collection.ID: CollectionDetailsFields],
		childCollectionDetailsFields: [CollectionDetailsFields]
	) {
		self.init(
			title: groupDetailsFields.title,
			sortIndex: groupDetailsFields.sortIndex,
			collections: groupDetailsFields.collections.map(\.id).enumerated().map { index, id in
				.init(
					groupID: .init(rawValue: groupDetailsFields.title),
					sortIndex: index,
					rootCollectionDetailsFields: rootCollectionDetailsFields[id]!,
					childCollectionDetailsFields: childCollectionDetailsFields
				)
			}
		)
	}
}
