// Copyright © Fleuronic LLC. All rights reserved.


import PersistDB
import DewdropDatabase

import struct Raindrop.Collection
import protocol Catenoid.Model

extension Collection {
	init(_ fields: CollectionTitleFields) {
		self.init(
			id: fields.id,
			title: fields.title,
			count: fields.count,
			isShared: false,
			collections: []
		)
	}
}

extension Collection: Model {
	public var valueSet: ValueSet<Collection.Identified> {
		[
			\.title == title,
			\.count == count
		]
	}
}
