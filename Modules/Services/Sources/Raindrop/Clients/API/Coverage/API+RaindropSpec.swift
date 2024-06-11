// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Tag
import struct DewdropAPI.API
import struct DewdropService.ImportFolderFields
import protocol Ergo.WorkerOutput
import protocol RaindropService.RaindropSpec

extension API: RaindropSpec {
	public func loadRaindrops(inCollectionWith id: Collection.ID) async -> Raindrop.LoadingResult {
		await api.listRaindrops(inCollectionWith: id).map { raindrops in
			raindrops.map { raindrop in
				// TODO
				.init(
					id: raindrop.id,
					collectionID: raindrop.collection.id,
					title: raindrop.title,
					url: raindrop.url
				)
			}
		}
	}

	public func loadRaindrops(taggedByTagNamed name: String) async -> Raindrop.LoadingResult {
		await api.listRaindrops(searchingFor: "#\"\(name)\"").map { raindrops in
			raindrops.map { raindrop in
				.init(
					id: raindrop.id,
					collectionID: raindrop.collection.id,
					title: raindrop.title,
					url: raindrop.url
				)
			}
		}
	}
}

// MARK: -
public extension Raindrop {
	typealias LoadingResult = API.Result<[Raindrop]>
}

