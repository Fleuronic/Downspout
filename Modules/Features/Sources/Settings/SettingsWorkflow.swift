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
		case basic
		case authorizationCode(String)
		case accessToken(AccessToken)
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

	public enum Output {
		case loginRequest(URL)
		case logoutRequest
		case termination
	}

	public func makeInitialState() -> State {
		.loggedOut
	}

	public func workflowDidChange(from previousWorkflow: Self, state: inout State) {
		switch (previousWorkflow.source, source) {
		case let (.basic, .authorizationCode(code)):
			state = .authenticating(code: code)
		case (_, .basic):
			state = .loggedOut
		default:
			break
		}
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> Settings.Screen {
		let workflows: [AnyWorkflow<Void, Action>] = switch state {
		case let .authenticating(code):
			[authenticationWorker(withAuthorizationCode: code).asAnyWorkflow()]
		default:
			[]
		}

		return context.render(workflows: workflows) { sink in
			.init(
				logIn: { sink.send(Action.logIn) },
				logOut: { sink.send(Action.logOut) },
				quit: { sink.send(Action.quit) },
				isLoggedIn: state ~= .loggedIn,
				isLoggedOut: state ~= .loggedOut
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
