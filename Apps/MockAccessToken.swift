// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.AccessToken
import struct Foundation.TimeInterval

extension AccessToken {
	static var mock: Self {
		.init(
			accessToken: "<ACCESS_TOKEN>",
			refreshToken: "<REFRESH_TOKEN>",
			expirationDuration: .infinity,
			tokenType: "Bearer",
			creationDate: .now
		)
	}
}
