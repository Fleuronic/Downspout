// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB
import DewdropDatabase

import struct Raindrop.Raindrop
import struct Raindrop.Highlight
import struct Raindrop.Tag
import struct DewdropService.IdentifiedRaindrop
import protocol Catenoid.Model

extension Raindrop {
	init(fields: RaindropListFields) {
		self.init(
			id: fields.id,
			collectionID: fields.collection.id,
			url: fields.url,
			title: fields.title,
			itemType: fields.itemType,
			isFavorite: fields.isFavorite,
			isBroken: fields.isBroken,
			taggings: nil, // Don’t need to display raindrop’s tags
			highlights: nil // Don’t need to display raindrop’s highlights
		)
	}
}

// MARK: -
public extension Raindrop {
	var valueSet: ValueSet<Identified> {
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

// MARK: -
#if compiler(>=6.0)
extension Raindrop: @retroactive Model {}
#else
extension Raindrop: Model {}
#endif
