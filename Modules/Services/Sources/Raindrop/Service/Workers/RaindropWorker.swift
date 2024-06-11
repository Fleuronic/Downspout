// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import protocol Ergo.WorkerOutput
import protocol Workflow.WorkflowAction
import protocol WorkflowConcurrency.Worker

@Init public struct RaindropWorker<Service: RaindropSpec, Action: WorkflowAction> {
	private let service: Service
	private let collectionID: Collection.ID
	private let success: (Service.RaindropLoadingResult.Success, Collection.ID) -> Action
	private let failure: (Service.RaindropLoadingResult.Failure) -> Action
}

extension RaindropWorker: WorkflowConcurrency.Worker {
	public func run() async -> Action {
		let result = await service.loadRaindrops(inCollectionWith: collectionID)
		return result.success.map { raindrops in
			success(raindrops, collectionID)
		} ?? result.failure.map(failure)!
	}

	public func isEquivalent(to worker: Self) -> Bool {
		collectionID == worker.collectionID
	}
}
