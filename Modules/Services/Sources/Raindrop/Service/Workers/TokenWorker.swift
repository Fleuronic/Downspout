// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro
import ReactiveSwift

import protocol Ergo.WorkerOutput
import protocol Workflow.WorkflowAction
import protocol WorkflowReactiveSwift.Worker

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
			completion: Action
		)
	}
}

// MARK: -
extension TokenWorker: Worker {
	public func run() -> SignalProducer<Action, Never> {
		.init { observer, _ in
			Task {
				switch request {
				case let .retrieve(success, failure):
					let results = await service.retrieveToken().results
					for await result in results {
						switch result {
						case let .success(token):
							observer.send(value: success(token))
						case let .failure(error):
							observer.send(value: failure(error))
						}
					}
				case let .discard(action):
					await service.discardToken()
					observer.send(value: action)
				}
				observer.sendCompleted()
			}
		}
	}

	public func isEquivalent(to otherWorker: TokenWorker<Service, Action>) -> Bool {
		true
	}
}

