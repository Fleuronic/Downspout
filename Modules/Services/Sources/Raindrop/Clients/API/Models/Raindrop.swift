// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop

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
