// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB
import DewdropDatabase

import struct Raindrop.Raindrop
import struct DewdropService.IdentifiedRaindrop
import protocol Catenoid.Model

extension Raindrop {
	init(fields: RaindropListFields) {
		self.init(
			id: fields.id,
			collectionID: fields.collection?.id,
			url: fields.url,
			title: fields.title,
			itemType: fields.itemType,
			isFavorite: fields.isFavorite,
			isBroken: fields.isBroken
		)
	}
}

// MARK: -
extension Raindrop: @retroactive Model {
	public var valueSet: ValueSet<Identified> {
		[
			\.value.url == url,
			\.value.title == title,
			\.value.itemType == itemType,
			\.value.isFavorite == isFavorite,
			\.value.isBroken == isBroken,
			\.collection == collectionID
		]
	}
}
