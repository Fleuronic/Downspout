// Copyright © Fleuronic LLC. All rights reserved.

import Workflow
import WorkflowReactiveSwift

import struct ReactiveSwift.SignalProducer
import protocol Ergo.WorkerOutput

public struct AuthenticationWorker<Service: AuthenticationSpec, Action: WorkflowAction & Sendable>: Sendable {
	private let service: Service
	private let authorizationCode: String
	private let success: @Sendable (Success) -> Action
	private let failure: @Sendable (Failure) -> Action

	public init(
		service: Service,
		authorizationCode: String,
		success: @Sendable @escaping (Success) -> Action,
		failure: @Sendable @escaping (Failure) -> Action
	) {
		self.service = service
		self.authorizationCode = authorizationCode
		self.success = success
		self.failure = failure
	}
}

// MARK: -
public extension AuthenticationWorker {
	typealias Result = Service.AuthenticationResult
	typealias Success = Result.Success
	typealias Failure = Result.Failure
}

// MARK: -
extension AuthenticationWorker: WorkflowReactiveSwift.Worker {
	public func run() -> SignalProducer<Action, Never> {
		.init { output in
			let results = await service.authenticate(withAuthorizationCode: authorizationCode).results
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

	public func isEquivalent(to otherWorker: Self) -> Bool {
		true
	}
}
