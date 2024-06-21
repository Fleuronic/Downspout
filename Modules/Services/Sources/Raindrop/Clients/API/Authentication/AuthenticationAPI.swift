// Copyright © Fleuronic LLC. All rights reserved.

import URL

import struct DewdropAPI.API
import struct DewdropAPI.Error
import enum DewdropAPI.Authentication
import struct Dewdrop.AccessToken
import struct Foundation.URL
import protocol Catena.API
import protocol Ergo.WorkerOutput
import protocol RaindropService.AuthenticationSpec

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
	public func authenticate(withAuthorizationCode code: String) async -> AccessToken.Result {
		let uri = #URL("http://downspout.fleuronic.com/auth")
		return await api.exchangeCodeForAccessToken(code: code, redirectingTo: uri)
	}

	public func reauthenticate(with token: AccessToken) async -> AccessToken.Result {
		await api.refreshAccessToken(token)
	}
}

// MARK: -
public extension AccessToken {
	typealias Result = API.Result<Self>
}

// MARK: -
extension Authentication.API: Catena.API {
	public typealias Error = DewdropAPI.Error
}
