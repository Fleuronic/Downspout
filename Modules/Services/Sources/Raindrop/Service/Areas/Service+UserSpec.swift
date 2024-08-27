// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.User
import protocol Ergo.WorkerOutput

extension Service: UserSpec where
	API: UserSpec,
	API.UserLoadResult == APIResult<User> {
	public func loadUser() async -> API.UserLoadResult {
		await api.loadUser()
	}
}
