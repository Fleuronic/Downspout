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
public extension Filter {
	// MARK: Model
	var valueSet: ValueSet<Identified> {
		[
			\.sortIndex == sortIndex,
			\.value.count == count
		]
	}
}

// MARK: -
#if compiler(>=6.0)
extension Filter: @retroactive Model {}
#else
extension Filter: Model {}
#endif

