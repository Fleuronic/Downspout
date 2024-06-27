// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import protocol Ergo.WorkerOutput

public protocol GroupSpec: Sendable {
	associatedtype GroupLoadResult: WorkerOutput<[Group]>

	func loadGroups() async -> GroupLoadResult
}
