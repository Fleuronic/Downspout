// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.User
import struct DewdropAPI.API
import protocol Catenary.API
import protocol Ergo.WorkerOutput
import protocol RaindropService.UserSpec

extension API: UserSpec {
	public func loadUser() async -> Self.Result<User> {
		await api.fetchUserAuthenticatedDetails().map(User.init)
	}
}
