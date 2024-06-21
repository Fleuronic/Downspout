// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Tag
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Foundation.UUID
import protocol RaindropService.TagSpec
import protocol RaindropService.RaindropSpec

struct MockRaindropDatabase {}

extension MockRaindropDatabase: TagSpec {
	func loadTags() -> [Tag] {
		[
			.init(name: "css", raindropCount: 1),
			.init(name: "design", raindropCount: 1),
			.init(name: "designer", raindropCount: 1),
			.init(name: "free", raindropCount: 4)
		]
	}
}

extension MockRaindropDatabase: RaindropSpec {
	public func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) -> [Raindrop] {
		fatalError()
	}

	public func loadRaindrops(taggedWithTagNamed name: String, count: Int) -> [Raindrop] {
		[
			.init(
				id: 0,
				collectionID: 0,
				title: "Raindrop",
				url: .init(string: "https://raindrop.io")!
			)
		]
	}

	public func loadRaindrops(filteredByFilterWith with: Filter.ID, count: Int) async -> [Raindrop] {
		fatalError()
	}
}
