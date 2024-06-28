// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import protocol Ergo.WorkerOutput

public protocol GroupSpec: Sendable {
	associatedtype GroupLoadResult: WorkerOutput<[Group]>
	associatedtype GroupSaveResult: WorkerOutput<[Group.ID]>

	func loadGroups() async -> GroupLoadResult

	func save(_ groups: [Group]) async -> GroupSaveResult
}
