// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import struct Dewdrop.Filter
import struct DewdropService.FilterCountFields

extension Raindrop.Filter {
	init(
		fields: FilterCountFields,
		sortIndex: Int
	) {
		self.init(
			id: fields.id,
			count: fields.count,
			sortIndex: sortIndex,
			raindrops: nil
		)
	}

	init?(
		idName: Raindrop.Filter.ID.Name,
		filter: Dewdrop.Filter?,
		sortIndex: Int
	) {
		guard let filter else { return nil }

		self.init(
			id: .init(idName),
			count: filter.count,
			sortIndex: sortIndex,
			raindrops: nil
		)
	}
}

