// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Filter
import struct ReactiveSwift.SignalProducer
import protocol Ergo.WorkerOutput
import protocol Workflow.WorkflowAction
import protocol WorkflowReactiveSwift.Worker

public struct FilterWorker<Service: FilterSpec, Action: WorkflowAction & Sendable>: Sendable {
	private let service: Service
	private let success: @Sendable (Success) -> Action
	private let failure: @Sendable(Failure) -> Action

	public init(
		service: Service,
		success: @Sendable @escaping (Success) -> Action,
		failure: @Sendable @escaping (Failure) -> Action
	) {
		self.service = service
		self.success = success
		self.failure = failure
	}
}

// MARK: -
public extension FilterWorker {
	typealias Result = Service.FilterLoadResult
	typealias Success = Result.Success
	typealias Failure = Result.Failure
}

// MARK: -
extension FilterWorker: WorkflowReactiveSwift.Worker {
	public func run() -> SignalProducer<Action, Never> {
		.init { output in
			let results = await service.loadFilters().results
			for await result in results {
				switch result {
				case let .success(value):
					output(success(value))
				case let .failure(error):
					output(failure(error))
				}
			}
		}
	}

	public func isEquivalent(to otherWorker: Self) -> Bool { true }
}
