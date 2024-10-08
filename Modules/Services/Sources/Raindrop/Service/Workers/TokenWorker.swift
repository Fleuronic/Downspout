// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro
import Workflow
import WorkflowReactiveSwift

import struct ReactiveSwift.SignalProducer
import protocol Ergo.WorkerOutput

@Init public struct TokenWorker<Service: TokenSpec, Action: WorkflowAction & Sendable>: Sendable {
	private let service: Service
	private let request: Request
}

// MARK: -
public extension TokenWorker {
	enum Request: Sendable {
		case retrieve(
			success: @Sendable (Service.RetrievalResult.Success) -> Action,
			failure: @Sendable (Service.RetrievalResult.Failure) -> Action
		)
		
		case discard(
			success: Action,
			failure: @Sendable (Service.StorageResult.Failure) -> Action
		)
	}
}

// MARK: -
extension TokenWorker: Worker {
	public func run() -> SignalProducer<Action, Never> {
		.init { output in
			switch request {
			case let .retrieve(success, failure):
				let results = await service.retrieveToken().results
				for await result in results {
					switch result {
					case let .success(token):
						output(success(token))
					case let .failure(error):
						output(failure(error))
					}
				}
			case let .discard(success, failure):
				let results = await service.discardToken().results
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
	}

	public func isEquivalent(to otherWorker: TokenWorker<Service, Action>) -> Bool {
		true
	}
}

