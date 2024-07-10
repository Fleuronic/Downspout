// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct DewdropService.RaindropDetailsFields

extension Raindrop {
	init(fields: RaindropDetailsFields) {
		self.init(
			id: fields.id,
			collectionID: fields.collection.id,
			title: fields.title,
			url: fields.url
		)
	}
}
