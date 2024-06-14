// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.AccessToken
import struct Foundation.URL
import protocol Ergo.WorkerOutput

public protocol AuthenticationSpec {
	associatedtype TokenResult: WorkerOutput

	func logIn(withAuthorizationCode: String) async -> TokenResult
}

public extension AuthenticationSpec {
	static var authorizationURL: URL {
		// TODO
		.init(string: "https://raindrop.io/oauth/authorize?redirect_uri=raindropdown://auth&client_id=666b714e8fd37ceb6302b129")!
	}
}
