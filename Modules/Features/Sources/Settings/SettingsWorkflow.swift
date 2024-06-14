// Copyright © Fleuronic LLC. All rights reserved.

import Ergo
import EnumKit

import struct Foundation.URL
import struct Dewdrop.AccessToken
import struct RaindropAPI.API
import class Workflow.RenderContext
import struct Workflow.AnyWorkflow
import protocol Workflow.Workflow
import protocol Workflow.WorkflowAction
import protocol RaindropService.AuthenticationSpec
import struct RaindropService.AuthenticationWorker
import WorkflowContainers
import WorkflowMenuUI

public extension Settings {
	struct Workflow<Service: AuthenticationSpec> where
		Service.TokenResult == AccessToken.Result {
		private let source: Source
		private let service: Service

		public init(
			source: Source,
			service: Service
		) {
			self.source = source
			self.service = service
		}
	}
}

// MARK: -
public extension Settings.Workflow {
	enum Source {
		case empty
		case authorizationCode(String)
		case accessToken
	}
}

// MARK: -
extension Settings.Workflow {
	enum Action: Equatable {
		case logIn
		case finishLogin(AccessToken)
		case logOut
		case quit
		case logError(AccessToken.Result.Error)
	}
}

// MARK: -
extension Settings.Workflow: Workflow {
	public enum State: CaseAccessible {
		case loggedIn
		case loggedOut
		case authenticating(code: String)
	}

	public enum Output: Equatable {
		case loginRequest(URL)
		case logoutRequest
		case termination
	}

	public func makeInitialState() -> State {
		switch source {
		case .accessToken: .loggedIn
		default: .loggedOut
		}
	}

	public func workflowDidChange(from previousWorkflow: Self, state: inout State) {
		switch (previousWorkflow.source, source) {
		case let (.empty, .authorizationCode(code)):
			state = .authenticating(code: code)
		case (_, .empty):
			state = .loggedOut
		default:
			break
		}
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> Menu.Section {
		context.render(
			workflows: state.authenticatingCode.map(authenticationWorker).map { worker in
				[worker.asAnyWorkflow()]
			} ?? []
		) { sink in
			.init(
				key: "Settings",
				screen: Settings.Screen(
					logIn: { sink.send(Action.logIn) },
					logOut: { sink.send(Action.logOut) },
					quit: { sink.send(Action.quit) },
					isLoggedIn: state ~= .loggedIn,
					isLoggedOut: state ~= .loggedOut
				).asAnyScreen()
			)
		}
	}
}

private extension Settings.Workflow {
	func authenticationWorker(withAuthorizationCode code: String) -> AuthenticationWorker<Service, Action> {
		.init(
			service: service,
			authorizationCode: code,
			success: Action.finishLogin,
			failure: Action.logError
		)
	}
}

private extension Settings.Workflow.State {
	var authenticatingCode: String? { associatedValue() }
}

// MARK: -
extension Settings.Workflow.Action: WorkflowAction {
	typealias WorkflowType = Settings.Workflow<Service>

	func apply(toState state: inout WorkflowType.State) -> WorkflowType.Output? { 
		switch self {
		case .logIn:
			return .loginRequest(Service.authorizationURL)
		case .logOut:
			return .logoutRequest
		case .finishLogin:
			state = .loggedIn
		case .quit:
			return .termination
		case let .logError(error):
			print(error)
			state = .loggedOut
		}
		return nil
	}
}
