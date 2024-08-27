// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.User

extension User {
	init(fields: UserDetailsFields) {
		self.init(
			id: fields.id,
			fullName: fields.fullName
		)
	}
}
