// Copyright © Fleuronic LLC. All rights reserved.

import Workflow
import WorkflowReactiveSwift

import struct ReactiveSwift.SignalProducer
import struct Foundation.URL
import protocol Ergo.WorkerOutput

public struct RaindropAddWorker<Service: AddSpec, Action: WorkflowAction & Sendable>: Sendable {
	private let service: Service
	private let url: URL
	private let success: Action
	private let failure: @Sendable (Failure) -> Action

	public init(
		service: Service,
		url: URL,
		success: Action,
		failure: @Sendable @escaping (Failure) -> Action
	) {
		self.service = service
		self.url = url
		self.success = success
		self.failure = failure
	}
}

// MARK: -
public extension RaindropAddWorker {
	typealias Result = Service.RaindropAddResult
	typealias Success = Result.Success
	typealias Failure = Result.Failure
}

// MARK: -
extension RaindropAddWorker: WorkflowReactiveSwift.Worker {
	public func run() -> SignalProducer<Action, Never> {
		.init { output in
			let results = await service.addRaindrop(with: url).results
			for await result in results {
				switch result {
				case .success:
					output(success)
				case let .failure(error):
					output(failure(error))
				}
			}
		}
	}

	public func isEquivalent(to worker: Self) -> Bool {
		url == worker.url
	}
}
