// Copyright © Fleuronic LLC. All rights reserved.

import Workflow
import WorkflowReactiveSwift

import struct ReactiveSwift.SignalProducer
import protocol Ergo.WorkerOutput

public struct CollectionWorker<Service: CollectionSpec, Action: WorkflowAction & Sendable>: Sendable {
	private let service: Service
	private let success: @Sendable (Success) -> Action
	private let failure: @Sendable (Failure) -> Action
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
public extension CollectionWorker {
	typealias Result = Service.CollectionLoadResult
	typealias Success = Result.Success
	typealias Failure = Result.Failure
}

// MARK: -
extension CollectionWorker: WorkflowReactiveSwift.Worker {
	public func run() -> SignalProducer<Action, Never> {
		.init { output in
			let results = await service.loadSystemCollections().results
			for await result in results {
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

	public func isEquivalent(to otherWorker: Self) -> Bool { true }
}
