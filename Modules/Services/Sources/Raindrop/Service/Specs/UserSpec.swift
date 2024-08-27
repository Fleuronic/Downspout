// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.User
import protocol Ergo.WorkerOutput

public protocol UserSpec: Sendable where UserLoadResult.Failure: Equatable & Sendable {
	associatedtype UserLoadResult: WorkerOutput<User>

	func loadUser() async -> UserLoadResult
}
