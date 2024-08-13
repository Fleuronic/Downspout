// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.User
import struct DewdropService.GroupDetailsFields
import struct DewdropService.UserAuthenticatedDetailsFields
import protocol DewdropService.UserFields

public struct UserGroupFields: UserFields {
	public let id: User.ID
	public let groups: [GroupDetailsFields]
}

// MARK: -
extension UserGroupFields: Decodable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: UserAuthenticatedDetailsFields.CodingKeys.self)

		try self.init(
			id: container.decode(for: .id),
			groups: container.decode(for: .groups)
		)
	}
}
