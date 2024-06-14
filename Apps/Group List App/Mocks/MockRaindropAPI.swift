// Copyright © Fleuronic LLC. All rights reserved.

import Dispatch

import struct Raindrop.Group
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import protocol RaindropService.GroupSpec
import protocol RaindropService.RaindropSpec

struct MockRaindropAPI {}

extension MockRaindropAPI: GroupSpec {
	func loadGroups() async -> Group.LoadingResult {
		.success(
			[
				.init(
					title: "Work",
					collections: [
						.init(
							id: 1,
							title: "Design Inspiration",
							count: 8,
							isShared: false,
							collections: [
								.init(
									id: 2,
									title: "Interior",
									count: 11,
									isShared: false,
									collections: []
								),
								.init(
									id: 3,
									title: "Interface",
									count: 9,
									isShared: false,
									collections: []
								),
								.init(
									id: 4,
									title: "Icons",
									count: 5,
									isShared: false,
									collections: []
								)
							]
						),
						.init(
							id: 5,
							title: "Apps",
							count: 5,
							isShared: false,
							collections: []
						)
					]
				),
				.init(
					title: "Home",
					collections: [
						.init(
							id: 6,
							title: "Buy",
							count: 7,
							isShared: false,
							collections: []
						),
						.init(
							id: 7,
							title: "Movies",
							count: 8,
							isShared: false,
							collections: []
						),
						.init(
							id: 8,
							title: "Plan next trip",
							count: 7,
							isShared: false,
							collections: []
						)
					]
				)
			]
		)
	}
}

extension MockRaindropAPI: RaindropSpec {
	public func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) async -> Raindrop.LoadingResult {
		.success(
			[
				.init(
					id: .init(rawValue: id.rawValue),
					collectionID: id,
					title: "Raindrop",
					url: .init(string: "https://raindrop.io")!
				)
			]
		)
	}
	
	public func loadRaindrops(taggedWithTagNamed name: String, count: Int) async -> Raindrop.LoadingResult {
		fatalError()
	}
	
	public func loadRaindrops(filteredByFilterWith with: Filter.ID, count: Int) async -> Raindrop.LoadingResult {
		fatalError()
	}
}
