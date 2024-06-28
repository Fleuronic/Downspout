// Copyright © Fleuronic LLC. All rights reserved.


import PersistDB
import DewdropDatabase

import struct Raindrop.Raindrop
import protocol Catenoid.Model

extension Raindrop {
	init(_ fields: RaindropListFields) {
		self.init(
			id: fields.id,
			collectionID: fields.collection.id,
			title: fields.title,
			url: fields.url
		)
	}
}

// MARK: -
extension Raindrop: Model {
	public var valueSet: ValueSet<Identified> {
		[
			\.title == title,
			\.url == url,
			\.collection.id == collectionID
		]
	}
}
