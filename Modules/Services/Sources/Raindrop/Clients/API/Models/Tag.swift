// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Tag
import struct DewdropService.TagCountFields

extension Tag {
	init(fields: TagCountFields) {
		self.init(
			name: fields.id.rawValue,
			count: fields.count,
			raindrops: nil
		)
	}
}
