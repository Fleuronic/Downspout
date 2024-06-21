// Copyright © Fleuronic LLC. All rights reserved.

import ReactiveSwift

import protocol Ergo.WorkerOutput
import struct Raindrop.Filter

extension Service: FilterSpec where
	API: FilterSpec,
	API.FilterLoadingResult == APIResult<[Filter]>,
	Database: FilterSpec,
	Database.FilterLoadingResult == [Filter] {
	public func loadFilters() async -> Stream<API.FilterLoadingResult> {
		let api = await api
		return .init { observer, _ in
			Task {
//				await observer.send(value: self.database.loadFilters()))
				switch await api.loadFilters() {
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
