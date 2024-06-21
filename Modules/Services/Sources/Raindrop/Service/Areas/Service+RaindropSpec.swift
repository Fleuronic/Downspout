// Copyright © Fleuronic LLC. All rights reserved.

import protocol Ergo.WorkerOutput
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter

extension Service: RaindropSpec where
	API: RaindropSpec,
	API.RaindropLoadingResult == APIResult<[Raindrop]> {
	public func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) async -> Stream<API.RaindropLoadingResult> {
		// TODO: Service extensions
		.init { observer, _ in
			Task {
				switch await self.api.loadRaindrops(inCollectionWith: id, count: count) {
				case let .success(raindrops):
					observer.send(value: raindrops)
				case let .failure(error):
					observer.send(error: error)
				}
				observer.sendCompleted()
			}
		}
	}

	public func loadRaindrops(taggedWithTagNamed name: String, count: Int) async -> Stream<API.RaindropLoadingResult> {
		.init { observer, _ in
			Task {
				switch await self.api.loadRaindrops(taggedWithTagNamed: name, count: count) {
				case let .success(raindrops):
					observer.send(value: raindrops)
				case let .failure(error):
					observer.send(error: error)
				}
				observer.sendCompleted()
			}
		}
	}

	public func loadRaindrops(filteredByFilterWith id: Filter.ID, count: Int) async -> Stream<API.RaindropLoadingResult> {
		.init { observer, _ in
			Task {
				switch await self.api.loadRaindrops(filteredByFilterWith: id, count: count) {
				case let .success(raindrops):
					observer.send(value: raindrops)
				case let .failure(error):
					observer.send(error: error)
				}
				observer.sendCompleted()
			}
		}
	}
}
