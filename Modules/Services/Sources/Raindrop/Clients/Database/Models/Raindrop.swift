// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB

import struct Raindrop.Raindrop
import struct DewdropDatabase.RaindropListFields
import struct DewdropService.IdentifiedRaindrop
import protocol Identity.Identifiable
import protocol Catenoid.Model

extension Raindrop {
	init(fields: RaindropListFields) {
		self.init(
			id: fields.id,
			collectionID: fields.collection?.id,
			title: fields.title,
			url: fields.url
		)
	}
}

// MARK: -
extension Raindrop: Model {
	public var valueSet: ValueSet<Identified> {
		[
			\.value.title == title,
			\.value.url == url,
			\.collection == collectionID
		]
	}
}
