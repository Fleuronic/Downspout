// Copyright © Fleuronic LLC. All rights reserved.

import URL

import enum DewdropAPI.Authentication
import enum RaindropService.RedirectTarget
import struct Foundation.URL
import struct Dewdrop.AccessToken
import struct DewdropAPI.API
import struct DewdropAPI.Error
import protocol Catenary.API
import protocol Ergo.WorkerOutput
import protocol RaindropService.AuthenticationSpec

public extension Authentication {
	struct API {
		private let api: DewdropAPI.Authentication.API

		public init() {
			api = .init(
				clientID: Self.clientID,
				clientSecret: Self.clientSecret
			)
		}
	}
}

// MARK: -
extension Authentication.API: Catenary.API {
	public typealias Error = DewdropAPI.Error
}

extension Authentication.API: AuthenticationSpec {
	public static let clientID = "666b714e8fd37ceb6302b129"
	public static let authorizationEndpoint = #URL("https://raindrop.io/oauth/authorize")

	public func authenticate(withAuthorizationCode code: String) async -> API.Result<AccessToken> {
		let uri = Self.redirectURI(for: .web)
		return await api.exchangeCodeForAccessToken(code: code, redirectingTo: uri)
	}

	public func reauthenticate(with token: AccessToken) async -> API.Result<AccessToken> {
		await api.refreshAccessToken(token)
	}

	public static func redirectURI(for target: RedirectTarget) -> URL {
		switch target {
		case .web: #URL("http://downspout.fleuronic.com/auth")
		case .app: #URL("downspout://auth")
		}
	}
}

// MARK: -
private extension Authentication.API {
	static let clientSecret = "043b918a-2d51-45d4-84ec-0eddb0bf318b"
}
