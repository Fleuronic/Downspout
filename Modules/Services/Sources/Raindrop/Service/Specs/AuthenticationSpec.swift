// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.AccessToken
import struct Foundation.URL
import protocol Ergo.WorkerOutput

public protocol AuthenticationSpec: Equatable, Sendable {
	associatedtype AuthenticationResult: WorkerOutput<AccessToken> & Sendable

	func authenticate(withAuthorizationCode: String) async -> AuthenticationResult
	func reauthenticate(with accessToken: AccessToken) async -> AuthenticationResult
}

public extension AuthenticationSpec {
	static var authorizationURL: URL {
		// TODO
		.init(string: "https://raindrop.io/oauth/authorize?redirect_uri=downspout://auth&client_id=666b714e8fd37ceb6302b129")!
	}
}
