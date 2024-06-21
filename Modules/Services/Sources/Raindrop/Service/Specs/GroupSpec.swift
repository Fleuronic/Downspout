// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import protocol Ergo.WorkerOutput

public protocol GroupSpec: Sendable where GroupLoadingResult.Failure: Equatable & Sendable {
	associatedtype GroupLoadingResult: WorkerOutput<[Group]>

	func loadGroups() async -> GroupLoadingResult
}
