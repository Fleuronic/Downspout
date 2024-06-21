// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.AccessToken
import struct Raindrop.Group
import protocol Catena.Database
import protocol Ergo.WorkerOutput
import protocol RaindropService.GroupSpec

extension Database: GroupSpec {
	public func loadGroups() -> [Group] {
		[
			.init(
				title: "Beep",
				collections: []
			)
		]
	}
}
