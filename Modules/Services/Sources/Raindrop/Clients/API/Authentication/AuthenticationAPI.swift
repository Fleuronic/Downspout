// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.AccessToken
import enum DewdropAPI.Authentication
import protocol Ergo.WorkerOutput
import protocol RaindropService.AuthenticationSpec
import struct Foundation.URL

import DewdropAPI
import DewdropService

public extension Authentication {
	struct API {
		private let api: DewdropAPI.Authentication.API

		public init() {
			api = .init(
				clientID: "666b714e8fd37ceb6302b129",
				clientSecret: "043b918a-2d51-45d4-84ec-0eddb0bf318b"
			)
		}
	}
}

extension Authentication.API: AuthenticationSpec {
	public func logIn(withAuthorizationCode code: String) async -> AccessToken.Result {
		let uri = URL(string: "http://raindropdown.fleuronic.com/auth")!
		return await api.exchangeCodeForAccessToken(code: code, redirectingTo: uri)
	}
}

// MARK: -
public extension AccessToken {
	typealias Result = API.Result<Self>
}
