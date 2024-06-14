// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import protocol Ergo.WorkerOutput
import protocol Workflow.WorkflowAction
import protocol WorkflowConcurrency.Worker

@Init public struct AuthenticationWorker<Service: AuthenticationSpec, Action: WorkflowAction> {
	private let service: Service
	private let authorizationCode: String
	private let success: (Success) -> Action
	private let failure: (Failure) -> Action
}

// MARK: -
public extension AuthenticationWorker {
	typealias Result = Service.TokenResult
	typealias Success = Result.Success
	typealias Failure = Result.Failure
}

// MARK: -
extension AuthenticationWorker: WorkflowConcurrency.Worker {
	public func run() async -> Action {
		let result = await service.logIn(withAuthorizationCode: authorizationCode)
		return result.success.map(success) ?? result.failure.map(failure)!
	}

	public func isEquivalent(to otherWorker: Self) -> Bool { true }
}
