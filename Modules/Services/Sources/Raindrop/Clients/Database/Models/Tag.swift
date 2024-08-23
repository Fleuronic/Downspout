// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB
import DewdropDatabase

import struct Raindrop.Tag
import struct Raindrop.Raindrop
import struct DewdropService.IdentifiedTag
import protocol Catenoid.Model

extension Tag {
	init(
		fields: TagListFields,
		raindrops: [Raindrop]
	) {
		self.init(
			name: fields.name,
			count: fields.count,
			raindrops: raindrops
		)
	}
}

// MARK: -
public extension Tag {
	// MARK: Model
	var valueSet: ValueSet<Identified> {
		[
			\.value.count == count
		]
	}
}

// MARK: -
#if compiler(>=6.0)
extension Tag: @retroactive Model {}
#else
extension Tag: Model {}
#endif
