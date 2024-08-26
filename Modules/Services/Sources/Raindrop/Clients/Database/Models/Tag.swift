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
extension Tag: Catenoid.Model {
	// MARK: Model
	public var valueSet: ValueSet<Identified> {
		[
			\.value.count == count
		]
	}
}
