// Copyright © Fleuronic LLC. All rights reserved.

import Workflow
import WorkflowReactiveSwift
import AuthenticationServices

import struct ReactiveSwift.SignalProducer
import struct Foundation.URL
import protocol Ergo.WorkerOutput

public struct LoginWorker<Service: AuthenticationSpec, Action: WorkflowAction & Sendable>: Sendable {
	private let contextProvider: ASWebAuthenticationPresentationContextProviding & Sendable
	private let success: @Sendable (String) -> Action
	private let failure: @Sendable (Error) -> Action

	public init(
		contextProvider: ASWebAuthenticationPresentationContextProviding & Sendable,
		success: @Sendable @escaping (String) -> Action,
		failure: @Sendable @escaping (Error) -> Action
	) {
		self.contextProvider = contextProvider
		self.success = success
		self.failure = failure
	}
}

// MARK: -
extension LoginWorker: WorkflowReactiveSwift.Worker {
	public func run() -> SignalProducer<Action, Never> {
		.init { output in
			let url = Service.authorizationURL
			let results = await logIn(withSessionFor: url, providedContextBy: contextProvider).results
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

// MARK: -
@MainActor
private func logIn(withSessionFor url: URL, providedContextBy contextProvider: ASWebAuthenticationPresentationContextProviding) async -> Result<String, Swift.Error> {
	await withCheckedContinuation { continuation in
		let session = ASWebAuthenticationSession(
			url: url,
			callbackURLScheme: "scheme"
		) { url, error in
			let code = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?.queryItems?.first?.value
			code.map { continuation.resume(returning: .success($0)) }
			error.map { continuation.resume(returning: .failure($0)) }
		}

		session.presentationContextProvider = contextProvider
		session.start()
	}
}
