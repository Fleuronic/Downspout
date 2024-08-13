// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import struct Raindrop.Raindrop
import struct Dewdrop.Group
import struct DewdropService.IdentifiedGroup
import struct DewdropService.IdentifiedCollection
import struct DewdropService.CollectionCountFields
import struct Foundation.KeyPathComparator

extension Collection {
	init?(fields: CollectionCountFields) {
		self.init(
			id: fields.id,
			count: fields.count,
			groupID: nil,
			parentID: nil
		)
	}

	init(
		groupID: Group.ID,
		sortIndex: Int,
		rootCollectionListFields: CollectionListFields,
		childCollectionListFields: [CollectionListFields]
	) {
		self.init(
			id: rootCollectionListFields.id,
			parentID: rootCollectionListFields.parent?.id,
			title: rootCollectionListFields.title,
			count: rootCollectionListFields.count,
			isShared: rootCollectionListFields.isShared,
			sortIndex: sortIndex,
			groupID: groupID,
			collections: children(
				id: rootCollectionListFields.id,
				fields: childCollectionListFields
			),
			raindrops: nil
		)
	}
}

// MARK: -
private func children(
	id: Collection.ID,
	fields: [CollectionListFields]
) -> [Collection] {
	fields.sorted(using: KeyPathComparator(\.sortIndex)).filter { $0.parent?.id == id }.map { collection in
		.init(
			id: collection.id,
			parentID: collection.parent?.id,
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
