// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro
import ReactiveSwift

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Raindrop.Tag
import protocol Ergo.WorkerOutput
import protocol Workflow.WorkflowAction
import protocol WorkflowReactiveSwift.Worker

public struct RaindropWorker<Service: RaindropSpec, Action: WorkflowAction & Sendable>: Sendable {
	private let service: Service
	private let source: Source
	private let count: Int
	private let success: @Sendable (Success) -> Action
	private let failure: @Sendable (Failure) -> Action
	private let completion: Action

	public init(
		service: Service,
		source: Source,
		count: Int,
		success: @Sendable @escaping (Success) -> Action,
		failure: @Sendable @escaping (Failure) -> Action,
		completion: Action
	) {
		self.service = service
		self.source = source
		self.count = count
		self.success = success
		self.failure = failure
		self.completion = completion
	}
}

// MARK: -
public extension RaindropWorker {
	enum Source: Equatable, Sendable {
		case collection(Collection.ID)
		case filter(Filter.ID)
		case tag(name: String)
	}

	typealias Result = Service.RaindropLoadingResult
	typealias Success = Result.Success
	typealias Failure = Result.Failure
}

// MARK: -
extension RaindropWorker: WorkflowReactiveSwift.Worker {
	public func run() -> SignalProducer<Action, Never> {
		.init { observer, _ in
			Task {
				let result = switch source {
				case let .collection(id):
					await service.loadRaindrops(inCollectionWith: id, count: count)
				case let .filter(id):
					await service.loadRaindrops(filteredByFilterWith: id, count: count)
				case let .tag(name):
					await service.loadRaindrops(taggedWithTagNamed: name, count: count)
				}

				for await result in result.results {
					switch result {
					case let .success(value):
						observer.send(value: success(value))
					case let .failure(error):
						observer.send(value: failure(error))
					}
				}

				observer.send(value: completion)
				observer.sendCompleted()
			}
		}
	}

	public func isEquivalent(to worker: Self) -> Bool {
		source == worker.source
	}
}
