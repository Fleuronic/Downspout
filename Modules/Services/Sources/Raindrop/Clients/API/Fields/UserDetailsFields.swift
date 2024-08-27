// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.User
import struct DewdropService.GroupDetailsFields
import struct DewdropService.UserAuthenticatedDetailsFields
import protocol DewdropService.UserFields

struct UserDetailsFields: UserFields {
	let id: User.ID
	let fullName: String
	let groups: [GroupDetailsFields]
}

// MARK: -
extension UserDetailsFields: Decodable {
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: UserAuthenticatedDetailsFields.CodingKeys.self)
		let userContainer = try decoder.container(keyedBy: User.CodingKeys.self)

		try self.init(
			id: container.decode(for: .id),
			fullName: userContainer.decode(for: .fullName),
			groups: container.decode(for: .groups)
		)
	}
}
