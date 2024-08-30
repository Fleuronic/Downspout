// Copyright © Fleuronic LLC. All rights reserved.

import Workflow
import WorkflowReactiveSwift

import struct Raindrop.Collection
import struct Raindrop.Filter
import struct ReactiveSwift.SignalProducer
import protocol Ergo.WorkerOutput

public struct RaindropLoadWorker<Service: RaindropSpec, Action: WorkflowAction & Sendable>: Sendable {
	private let service: Service
	private let source: Source
	private let success: @Sendable (Success) -> Action
	private let failure: @Sendable (Failure) -> Action
	private let completion: Action

	public init(
		service: Service,
		source: Source,
		success: @Sendable @escaping (Success) -> Action,
		failure: @Sendable @escaping (Failure) -> Action,
		completion: Action
	) {
		self.service = service
		self.source = source
		self.success = success
		self.failure = failure
		self.completion = completion
	}
}

// MARK: -
public extension RaindropLoadWorker {
	enum Source: Equatable, Sendable {
		case collection(Collection.ID, count: Int)
		case filter(Filter.ID, count: Int)
		case tag(name: String, count: Int)
	}

	typealias Result = Service.RaindropLoadResult
	typealias Success = Result.Success
	typealias Failure = Result.Failure
}

// MARK: -
extension RaindropLoadWorker: WorkflowReactiveSwift.Worker {
	public func run() -> SignalProducer<Action, Never> {
		.init { output in
			let result = switch source {
			case let .collection(id, count):
				await service.loadRaindrops(inCollectionWith: id, count: count)
			case let .filter(id, count):
				await service.loadRaindrops(filteredByFilterWith: id, count: count)
			case let .tag(name, count):
				await service.loadRaindrops(taggedWithTagNamed: name, count: count)
			}

			for await result in result.results {
				switch result {
				case let .success(value):
					output(success(value))
				case let .failure(error):
					output(failure(error))
				}
			}

			output(completion)
		}
	}

	public func isEquivalent(to worker: Self) -> Bool {
		source == worker.source
	}
}
