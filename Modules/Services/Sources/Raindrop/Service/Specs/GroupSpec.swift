// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import protocol Ergo.WorkerOutput

public protocol GroupSpec {
	associatedtype GroupLoadingResult: WorkerOutput

	func loadGroups() async -> GroupLoadingResult
}
