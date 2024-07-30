// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import struct Raindrop.Raindrop
import struct Dewdrop.Group
import struct DewdropService.IdentifiedGroup
import struct DewdropService.IdentifiedCollection
import struct DewdropService.CollectionCountFields
import struct DewdropService.CollectionDetailsFields

extension Collection {
	init?(fields: CollectionCountFields) {
		self.init(
			id: fields.id,
			count: fields.count,
			groupID: nil,
			parentID: nil
		)
	}

	init(fields: CollectionDetailsFields) {
		self.init(
			id: fields.id,
			parentID: fields.parentID,
			title: fields.title,
			count: fields.count,
			isShared: fields.isShared,
			sortIndex: fields.sortIndex,
			groupID: nil,
			collections: [],
			raindrops: nil
		)
	}

	init(
		groupID: Group.ID,
		sortIndex: Int,
		rootCollectionDetailsFields: CollectionDetailsFields,
		childCollectionDetailsFields: [CollectionDetailsFields]
	) {
		self.init(
			id: rootCollectionDetailsFields.id,
			parentID: rootCollectionDetailsFields.parentID,
			title: rootCollectionDetailsFields.title,
			count: rootCollectionDetailsFields.count,
			isShared: rootCollectionDetailsFields.isShared,
			sortIndex: sortIndex,
			groupID: groupID,
			collections: children(
				id: rootCollectionDetailsFields.id,
				fields: childCollectionDetailsFields
			),
			raindrops: nil
		)
	}
}

// MARK: -
private func children(
	id: Collection.ID,
	fields: [CollectionDetailsFields]
) -> [Collection] {
	fields.filter { $0.parentID == id }.map { collection in
		.init(
			id: collection.id,
			parentID: collection.parentID,
			title: collection.title,
			count: collection.count,
			isShared: collection.isShared,
			sortIndex: collection.sortIndex,
			groupID: nil,
			collections: children(
				id: collection.id,
				fields: fields
			),
			raindrops: nil
		)
	}
}
