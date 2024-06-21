// Copyright © Fleuronic LLC. All rights reserved.

import ReactiveSwift

import protocol Ergo.WorkerOutput
import struct Raindrop.Tag

extension Service: TagSpec where
	API: TagSpec,
	API.TagLoadingResult == APIResult<[Tag]>,
	Database: TagSpec,
	Database.TagLoadingResult == [Tag] {
	public func loadTags() -> Stream<API.TagLoadingResult> {
		.init { observer, _ in
			Task {
//				await observer.send(value: database.loadTags())
				switch await self.api.loadTags() {
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
