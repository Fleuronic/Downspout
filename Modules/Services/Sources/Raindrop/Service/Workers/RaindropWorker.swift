// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Raindrop.Tag
import protocol Ergo.WorkerOutput
import protocol Workflow.WorkflowAction
import protocol WorkflowConcurrency.Worker

@Init public struct RaindropWorker<Service: RaindropSpec, Action: WorkflowAction> {
	private let service: Service
	private let source: Source
	private let count: Int
	private let success: (Success) -> Action
	private let failure: (Failure) -> Action
}

// MARK: -
public extension RaindropWorker {
	enum Source: Equatable {
		case collection(Collection.ID)
		case filter(Filter.ID)
		case tag(name: String)
	}

	typealias Result = Service.RaindropLoadingResult
	typealias Success = Result.Success
	typealias Failure = Result.Failure
}

// MARK: -
extension RaindropWorker: WorkflowConcurrency.Worker {
	public func run() async -> Action {
		let result = switch source {
		case let .collection(id):
			await service.loadRaindrops(inCollectionWith: id, count: count)
		case let .filter(id):
			await service.loadRaindrops(filteredByFilterWith: id, count: count)
		case let .tag(name):
			await service.loadRaindrops(taggedWithTagNamed: name, count: count)
		}

		return result.success.map { raindrops in
			success(raindrops)
		} ?? result.failure.map(failure)!
	}

	public func isEquivalent(to worker: Self) -> Bool {
		source == worker.source
	}
}
