// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.AccessToken
import struct Raindrop.Tag
import protocol Catena.Database
import protocol Ergo.WorkerOutput
import protocol RaindropService.TagSpec

extension Database: TagSpec {
	public func loadTags() -> [Tag] {
		[
			.init(
				name: "Beep",
				raindropCount: 0
			)
		]
	}
}
