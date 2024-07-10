// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import struct Dewdrop.Filter
import struct DewdropService.FilterCountFields

extension Raindrop.Filter {
	init(fields: FilterCountFields) {
		self.init(
			id: fields.id,
			count: fields.count,
			raindrops: nil
		)
	}

	init?(
		idName: Raindrop.Filter.ID.Name,
		filter: Dewdrop.Filter?
	) {
		guard let filter else { return nil }

		self.init(
			id: .init(idName),
			count: filter.count,
			raindrops: nil
		)
	}
}

