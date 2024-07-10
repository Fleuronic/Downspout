// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Tag
import struct DewdropService.TagCountFields

extension Tag {
	init(fields: TagCountFields) {
		self.init(
			name: fields.id.rawValue,
			raindropCount: fields.count,
			raindrops: nil
		)
	}
}
