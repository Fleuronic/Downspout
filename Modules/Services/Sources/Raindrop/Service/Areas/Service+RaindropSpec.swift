// Copyright © Fleuronic LLC. All rights reserved.

import protocol Ergo.WorkerOutput
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter

extension Service: RaindropSpec where
	API: RaindropSpec,
	API.RaindropLoadingResult == APIResult<[Raindrop]> {
	public func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) async -> Stream<API.RaindropLoadingResult> {
		await loadRaindrops(
			apiResult: { api in 
				await api.loadRaindrops(inCollectionWith: id, count: count) 
			}
		)
	}

	public func loadRaindrops(taggedWithTagNamed name: String, count: Int) async -> Stream<API.RaindropLoadingResult> {
		await loadRaindrops(
			apiResult: { api in 
				await api.loadRaindrops(taggedWithTagNamed: name, count: count)
			}
		)
	}

	public func loadRaindrops(filteredByFilterWith id: Filter.ID, count: Int) async -> Stream<API.RaindropLoadingResult> {
		await loadRaindrops(
			apiResult: { api in
				await api.loadRaindrops(filteredByFilterWith: id, count: count)				
			}
		)
	}
}

// MARK: -
private extension Service where
	API: RaindropSpec,
	API.RaindropLoadingResult == APIResult<[Raindrop]> {
	func loadRaindrops(
		apiResult: @escaping (API) async -> API.RaindropLoadingResult
		// databaseResult: () -> [Raindrop]
	) async -> Stream<API.RaindropLoadingResult> {
		let api = await api
		return .init { observer, _ in
			Task {
				switch await apiResult(api) {
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
