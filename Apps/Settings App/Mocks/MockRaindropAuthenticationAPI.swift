// Copyright © Fleuronic LLC. All rights reserved.

import Dispatch

import struct Dewdrop.AccessToken
import struct Foundation.TimeInterval
import protocol RaindropService.AuthenticationSpec

struct MockRaindropAuthenticationAPI {}

extension MockRaindropAuthenticationAPI: AuthenticationSpec {
	func logIn(withAuthorizationCode: String) async -> AccessToken.Result {
		.success(
			.init(
				accessToken: "<ACCESS_TOKEN>",
				refreshToken: "<REFRESH_TOKEN>",
				expirationDuration: .infinity,
				tokenType: "Bearer"
			)
		)
	}
}
