// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Raindrop.Collection
import protocol Ergo.WorkerOutput
import protocol Workflow.WorkflowAction
import protocol WorkflowConcurrency.Worker

@Init public struct CollectionWorker<Service: CollectionSpec, Action: WorkflowAction> {
	private let service: Service
	private let success: (Success) -> Action
	private let failure: (Failure) -> Action
}

// MARK: -
public extension CollectionWorker {
	typealias Result = Service.CollectionLoadingResult
	typealias Success = Result.Success
	typealias Failure = Result.Failure
}

// MARK: -
extension CollectionWorker: WorkflowConcurrency.Worker {
	public func run() async -> Action {
		let result = await service.loadSystemCollections()
		return result.success.map(success) ?? result.failure.map(failure)!
	}

	public func isEquivalent(to otherWorker: Self) -> Bool { true }
}
