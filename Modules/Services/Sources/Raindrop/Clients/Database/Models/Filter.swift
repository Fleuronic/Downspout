// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB

import struct Raindrop.Filter
import struct DewdropDatabase.FilterListFields
import struct DewdropService.IdentifiedFilter
import protocol Catenoid.Model

extension Filter {
	init(fields: FilterListFields) {
		self.init(
			id: fields.id,
			count: fields.count,
			raindrops: nil
		)
	}
}

// MARK: -
extension Filter: @retroactive Model {
	// MARK: Model
	public var valueSet: ValueSet<Identified> {
		[\.value.count == count]
	}
}
