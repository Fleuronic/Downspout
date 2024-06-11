// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Raindrop.Tag
import protocol Ergo.WorkerOutput
import protocol Workflow.WorkflowAction
import protocol WorkflowConcurrency.Worker

@Init public struct TagWorker<Service: TagSpec, Action: WorkflowAction> {
	private let service: Service
	private let success: (Success) -> Action
	private let failure: (Failure) -> Action
}

// MARK: -
public extension TagWorker {
	typealias Result = Service.TagLoadingResult
	typealias Success = Result.Success
	typealias Failure = Result.Failure
}

// MARK: -
extension TagWorker: WorkflowConcurrency.Worker {
	public func run() async -> Action {
		let result = await service.loadTags()
		return result.success.map(success) ?? result.failure.map(failure)!
	}

	public func isEquivalent(to otherWorker: Self) -> Bool { true }
}
