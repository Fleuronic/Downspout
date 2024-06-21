// Copyright © Fleuronic LLC. All rights reserved.

import ReactiveSwift

import protocol Ergo.WorkerOutput
import struct Raindrop.Group

extension Service: GroupSpec where
	API: GroupSpec,
	API.GroupLoadingResult == APIResult<[Group]>,
	Database: GroupSpec,
	Database.GroupLoadingResult == [Group] {
	public func loadGroups() async -> Stream<API.GroupLoadingResult> {
		let api = await api
		return .init { observer, _ in
			Task {
//				await observer.send(value: database.loadGroups())
				switch await api.loadGroups() {
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
