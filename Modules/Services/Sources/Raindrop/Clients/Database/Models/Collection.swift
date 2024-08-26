// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB
import DewdropDatabase

import struct Raindrop.Collection
import struct Raindrop.Raindrop
import struct DewdropService.IdentifiedCollection
import protocol Catenoid.Model

extension Collection {
	init(
		fields: SystemCollectionListFields,
		raindrops: [Raindrop]
	) {
		self.init(
			id: fields.id,
			parentID: nil, // System collections have no parent collection
			title: fields.title,
			count: fields.count,
			isShared: false, // System collections are not shared
			sortIndex: 0, // System collections are manually assigned a sort index
			groupID: nil, // System collections are not grouped
			collections: [], // System collections have no child collections
			raindrops: raindrops
		)
	}
}

// MARK: -
extension Collection: Catenoid.Model {
	// MARK: Model
	public var valueSet: ValueSet<Identified> {
		[
			\.parentID == parentID,
			\.value.title == title,
			\.value.count == count,
			\.value.isShared == isShared,
			\.value.sortIndex == sortIndex,
			\.group == groupID
		]
	}
}
