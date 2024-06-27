// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import protocol Ergo.WorkerOutput

extension Service: GroupSpec where
	API: GroupSpec,
	API.GroupLoadResult == APIResult<[Group]> {
	public func loadGroups() async -> API.GroupLoadResult {
		await api.loadGroups()
	}
}
