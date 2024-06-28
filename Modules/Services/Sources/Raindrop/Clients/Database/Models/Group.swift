// Copyright © Fleuronic LLC. All rights reserved.


import PersistDB
import DewdropDatabase

import struct Raindrop.Group
import protocol Catenoid.Model

extension Group {
	init(_ fields: GroupListFields) {
		self.init(
			title: fields.title,
			collections: []
		)
	}
}

extension Group: Model {
	public var valueSet: ValueSet<Identified> {
		[
			\.id == id
		]
	}
}
