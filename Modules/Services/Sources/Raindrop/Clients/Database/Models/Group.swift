// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB
import DewdropDatabase

import struct Raindrop.Group
import struct Raindrop.Collection
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
public extension Group {
	// MARK: Model
	var valueSet: ValueSet<Identified> {
		[
			\.value.sortIndex == sortIndex,
			\.value.isHidden == false
		]
	}
}

// MARK: -
#if compiler(>=6.0)
extension Group: @retroactive Model {}
#else
extension Group: Model {}
#endif
