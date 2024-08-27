// Copyright © Fleuronic LLC. All rights reserved.

import Workflow
import WorkflowReactiveSwift

import struct ReactiveSwift.SignalProducer
import protocol Ergo.WorkerOutput

public struct UserWorker<Service: UserSpec, Action: WorkflowAction & Sendable>: Sendable {
	private let service: Service
	private let success: @Sendable (Success) -> Action
	private let failure: @Sendable(Failure) -> Action

	public init(
		service: Service,
		success: @Sendable @escaping (Success) -> Action,
		failure: @Sendable @escaping (Failure) -> Action
	) {
		self.success = success
		self.failure = failure
		self.service = service
	}
}

// MARK: -
public extension UserWorker {
	typealias Result = Service.UserLoadResult
	typealias Success = Result.Success
	typealias Failure = Result.Failure
}

// MARK: -
extension UserWorker: WorkflowReactiveSwift.Worker {
	public func run() -> SignalProducer<Action, Never> {
		.init { output in
			let results = await service.loadUser().results
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
