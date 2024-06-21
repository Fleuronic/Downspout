// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.AccessToken
import protocol RaindropService.AuthenticationSpec

struct MockRaindropAuthenticationAPI {}

extension MockRaindropAuthenticationAPI: AuthenticationSpec {
	func authenticate(withAuthorizationCode: String) -> AccessToken? { .mock }
}
