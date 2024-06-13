// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Raindrop.Filter
import protocol Ergo.WorkerOutput
import protocol Workflow.WorkflowAction
import protocol WorkflowConcurrency.Worker

@Init public struct FilterWorker<Service: FilterSpec, Action: WorkflowAction> {
	private let service: Service
	private let success: (Success) -> Action
	private let failure: (Failure) -> Action
}

// MARK: -
public extension FilterWorker {
	typealias Result = Service.FilterLoadingResult
	typealias Success = Result.Success
	typealias Failure = Result.Failure
}

// MARK: -
extension FilterWorker: WorkflowConcurrency.Worker {
	public func run() async -> Action {
		let result = await service.loadFilters()
		return result.success.map(success) ?? result.failure.map(failure)!
	}

	public func isEquivalent(to otherWorker: Self) -> Bool { true }
}
