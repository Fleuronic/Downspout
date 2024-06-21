// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.AccessToken
import struct Raindrop.Collection
import protocol Catena.Database
import protocol Ergo.WorkerOutput
import protocol RaindropService.CollectionSpec

extension Database: CollectionSpec {
	public func loadSystemCollections() -> [Collection] {
		[.init(id: -2, title: "Beep", count: 0, isShared: false, collections: [])]
	}
}
