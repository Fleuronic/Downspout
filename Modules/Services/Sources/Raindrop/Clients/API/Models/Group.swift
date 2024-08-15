// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import struct Raindrop.Collection
import struct Dewdrop.Collection
import struct DewdropService.IdentifiedCollection
import struct DewdropService.GroupDetailsFields

extension Group {
	init(
		groupDetailsFields: GroupDetailsFields,
		sortIndex: Int,
		rootCollectionListFields: [Dewdrop.Collection.ID: CollectionListFields],
		childCollectionListFields: [CollectionListFields]
	) {
		self.init(
			title: groupDetailsFields.title,
			sortIndex: sortIndex,
			collections: groupDetailsFields.collections.map(\.id).enumerated().map { index, id in
				.init(
					groupID: .init(rawValue: groupDetailsFields.title),
					sortIndex: index,
					rootCollectionListFields: rootCollectionListFields[id]!,
					childCollectionListFields: childCollectionListFields
				)
			}
		)
	}
}
