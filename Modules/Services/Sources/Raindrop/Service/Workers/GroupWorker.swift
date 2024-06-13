// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Raindrop.Group
import protocol Ergo.WorkerOutput
import protocol Workflow.WorkflowAction
import protocol WorkflowConcurrency.Worker

@Init public struct GroupWorker<Service: GroupSpec, Action: WorkflowAction> {
	private let service: Service
	private let success: (Success) -> Action
	private let failure: (Failure) -> Action
}

// MARK: -
public extension GroupWorker {
	typealias Result = Service.GroupLoadingResult
	typealias Success = Result.Success
	typealias Failure = Result.Failure
}

// MARK: -
extension GroupWorker: WorkflowConcurrency.Worker {
	public func run() async -> Action {
		let result = await service.loadGroups()
		return result.success.map(success) ?? result.failure.map(failure)!
	}

	public func isEquivalent(to otherWorker: Self) -> Bool { true }
}