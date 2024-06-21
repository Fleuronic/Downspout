// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.AccessToken
import protocol RaindropService.TokenSpec

actor MockRaindropDatabase {
	private var accessToken: AccessToken?

	init(accessToken: AccessToken? = nil) {
		self.accessToken = accessToken
	}
}

extension MockRaindropDatabase: TokenSpec {
	public func store(_ token: AccessToken) -> Result<Void, Never> {
		accessToken = token
		return .success(())
	}
	
	public func retrieveToken() -> Result<AccessToken?, Never> {
		.success(accessToken)
	}
	
	public func discardToken() {
		accessToken = nil
	}
}
