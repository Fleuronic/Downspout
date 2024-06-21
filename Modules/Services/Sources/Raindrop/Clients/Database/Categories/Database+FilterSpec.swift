// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.AccessToken
import struct Raindrop.Filter
import protocol Catena.Database
import protocol Ergo.WorkerOutput
import protocol RaindropService.FilterSpec

extension Database: FilterSpec {
	public func loadFilters() -> [Filter] {
		[
			.init(
				id: .init(.favorited),
				count: 3
			)
		]
	}
}
