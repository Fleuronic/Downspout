// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB
import DewdropDatabase

import struct Raindrop.Filter
import struct Raindrop.Raindrop
import struct DewdropService.IdentifiedFilter
import protocol Catenoid.Model

extension Filter {
	init(
		fields: FilterListFields,
		sortIndex: Int,
		raindrops: [Raindrop]
	) {
		self.init(
			id: fields.id,
			count: fields.count,
			sortIndex: sortIndex,
			raindrops: raindrops
		)
	}
}

// MARK: -
extension Filter: Catenoid.Model {
	// MARK: Model
	public var valueSet: ValueSet<Identified> {
		[
			\.sortIndex == sortIndex,
			\.value.count == count
		]
	}
}
