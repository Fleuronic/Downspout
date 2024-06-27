// Copyright © Fleuronic LLC. All rights reserved.

import ReactiveSwift

import struct Raindrop.Tag
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import protocol Ergo.WorkerOutput
import protocol RaindropService.TagSpec
import protocol RaindropService.RaindropSpec

struct MockRaindropService {
	let api = MockRaindropAPI()
	let database = MockRaindropDatabase()
}

extension MockRaindropService {
	typealias Stream<Result: WorkerOutput> = SignalProducer<Result.Success, Result.Failure>
}

extension MockRaindropService: TagSpec {
	func loadTags() -> Stream<[Tag]> {
		.init { observer, lifetime in
			let task = Task {
				observer.send(value: database.loadTags())
				try! await Task.sleep(for: .milliseconds(300))
				observer.send(value: api.loadTags())
				observer.sendCompleted()
			}

			lifetime.observeEnded {
				task.cancel()
			}
		}
	}
}

extension MockRaindropService: RaindropSpec {
	public func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) -> Stream<[Raindrop]> {
		fatalError()
	}

	public func loadRaindrops(taggedWithTagNamed name: String, count: Int) -> Stream<[Raindrop]> {
		.init { observer, lifetime in
			let task = Task {
				observer.send(value: database.loadRaindrops(taggedWithTagNamed: name, count: count))
				try! await Task.sleep(for: .milliseconds(300))
				observer.send(value: api.loadRaindrops(taggedWithTagNamed: name, count: count))
				observer.sendCompleted()
			}

			lifetime.observeEnded {
				task.cancel()
			}
		}
	}

	public func loadRaindrops(filteredByFilterWith with: Filter.ID, count: Int) -> Stream<[Raindrop]> {
		fatalError()
	}
}
