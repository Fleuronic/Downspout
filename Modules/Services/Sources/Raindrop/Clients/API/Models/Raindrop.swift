// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Highlight
import struct Raindrop.Tag

extension Raindrop {
	init(fields: RaindropListFields) {
		self.init(
			id: fields.id,
			collectionID: fields.collection?.id,
			url: fields.url,
			title: fields.title,
			itemType: fields.itemType,
			isFavorite: fields.isFavorite,
			isBroken: fields.isBroken,
			taggings: fields.tags.map { tag in
				.init(
					raindropID: fields.id,
					tagName: tag.name
				)
			},
			highlights: fields.highlights.map { highlights in
				highlights.map { highlight in
					.init(
						fields: highlight,
						raindropID: fields.id
					)
				}
			} ?? []
		)
	}

	init(fields: RaindropCreationFields) {
		self.init(
			id: fields.id,
			collectionID: .unsorted,
			url: fields.url,
			title: fields.title,
			itemType: fields.itemType,
			isFavorite: false,
			isBroken: false,
			taggings: nil,
			highlights: nil
		)
	}
}
