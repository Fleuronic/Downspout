// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB

import struct Raindrop.Group
import struct Raindrop.Collection
import struct DewdropDatabase.GroupListFields
import struct DewdropService.IdentifiedGroup
import protocol Catenoid.Model

extension Group {
	init(
		fields: GroupListFields,
		collections: [Collection]
	) {
		self.init(
			title: fields.title,
			sortIndex: fields.sortIndex,
			collections: collections
		)
	}
}

// MARK: -
extension Group: Model {
	// MARK: Model
	public var valueSet: ValueSet<Identified> {
		[\.value.sortIndex == sortIndex]
	}
}
