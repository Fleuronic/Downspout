// Copyright © Fleuronic LLC. All rights reserved.

import ReactiveSwift

import protocol Ergo.WorkerOutput
import struct Raindrop.Collection

extension Service: CollectionSpec where
	API: CollectionSpec,
	API.CollectionLoadingResult == APIResult<[Collection]>,
	Database: CollectionSpec,
	Database.CollectionLoadingResult == [Collection] {
	public func loadSystemCollections() async -> Stream<API.CollectionLoadingResult> {
		let api = await api
		return .init { observer, _ in
			Task {
//				await observer.send(value: database.loadSystemCollections())
				switch await api.loadSystemCollections() {
				case let .success(collections):
					observer.send(value: collections)
				case let .failure(error):
					observer.send(error: error)
				}
				observer.sendCompleted()
			}
		}
	}
}
