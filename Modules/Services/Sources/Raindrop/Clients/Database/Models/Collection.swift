// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB

import struct Raindrop.Collection
import struct Raindrop.Raindrop
import struct DewdropDatabase.CollectionListFields
import struct DewdropDatabase.ChildCollectionListFields
import struct DewdropDatabase.SystemCollectionListFields
import struct DewdropService.CollectionDetailsFields
import protocol Catenoid.Model

extension Collection {
	init(
		fields: SystemCollectionListFields,
		raindrops: [Raindrop]
	) {
		self.init(
			id: fields.id,
			title: fields.title,
			count: fields.count,
			isShared: false, // TODO
			groupID: nil,
			parentID: nil,
			collections: [],
			raindrops: raindrops
		)
	}
}

// MARK: -
extension Collection: Model {
	public var valueSet: ValueSet<Identified> {
		[
			\.parentID == parentID,
			\.value.title == title,
			\.value.count == count,
			\.group == groupID
		]
	}
}
