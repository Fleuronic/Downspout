// Copyright © Fleuronic LLC. All rights reserved.

import ReactiveSwift

import struct Raindrop.Filter
import protocol Ergo.WorkerOutput
import protocol Workflow.WorkflowAction
import protocol WorkflowReactiveSwift.Worker

public struct FilterWorker<Service: FilterSpec, Action: WorkflowAction & Sendable>: Sendable {
	private let service: Service
	private let success: @Sendable (Success) -> Action
	private let failure: @Sendable(Failure) -> Action
	private let completion: Action

	public init(
		service: Service,
		success: @Sendable @escaping (Success) -> Action,
		failure: @Sendable @escaping (Failure) -> Action,
		completion: Action
	) {
		self.service = service
		self.success = success
		self.failure = failure
		self.completion = completion
	}
}

// MARK: -
public extension FilterWorker {
	typealias Result = Service.FilterLoadingResult
	typealias Success = Result.Success
	typealias Failure = Result.Failure
}

// MARK: -
extension FilterWorker: WorkflowReactiveSwift.Worker {
	public func run() -> SignalProducer<Action, Never> {
		.init { observer, _ in
			Task {
				let results = await service.loadFilters().results
				for await result in results {
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

	public func isEquivalent(to otherWorker: Self) -> Bool { true }
}
