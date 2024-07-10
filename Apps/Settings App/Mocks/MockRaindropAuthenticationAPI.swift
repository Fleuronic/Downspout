// Copyright © Fleuronic LLC. All rights reserved.

import URL

import enum RaindropService.RedirectTarget
import struct Foundation.URL
import struct Dewdrop.AccessToken
import protocol RaindropService.AuthenticationSpec

struct MockRaindropAuthenticationAPI {}

extension MockRaindropAuthenticationAPI: AuthenticationSpec {
	public static let clientID = "666b714e8fd37ceb6302b129"
	public static let authorizationEndpoint = #URL("https://raindrop.io/oauth/authorize")

	public func authenticate(withAuthorizationCode code: String) async -> AccessToken? {
		.mock
	}

	public func reauthenticate(with token: AccessToken) async -> AccessToken? {
		.mock
	}

	public static func redirectURI(for target: RedirectTarget) -> URL {
		switch target {
		case .web: #URL("http://downspout.fleuronic.com/auth")
		case .app: #URL("downspoutSettings://")
		}
	}
}
