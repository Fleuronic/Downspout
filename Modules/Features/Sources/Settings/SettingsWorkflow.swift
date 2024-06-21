// Copyright © Fleuronic LLC. All rights reserved.

import Workflow
import EnumKit

import struct Foundation.URL
import struct RaindropService.AuthenticationWorker
import struct RaindropService.TokenWorker
import typealias Ergo.SideEffect
import protocol Ergo.WorkerOutput
import protocol RaindropService.AuthenticationSpec
import protocol RaindropService.TokenSpec

extension Settings {
	public struct Workflow<
		AuthenticationService: AuthenticationSpec,
		TokenService: TokenSpec> where 
		AuthenticationService.AuthenticationResult.Success == TokenService.Token {
		private let source: Source
		private let authenticationService: AuthenticationService
		private let tokenService: TokenService
		
		public init(
			source: Source,
			authenticationService: AuthenticationService,
			tokenService: TokenService
		) {
			self.source = source
			self.authenticationService = authenticationService
			self.tokenService = tokenService
		}
	}
}

// MARK: -
public extension Settings.Workflow {
	typealias Token = TokenService.Token

	enum Source: CaseAccessible {
		case empty
		case authorizationCode(String)
	}
}

// MARK: -
extension Settings.Workflow: Workflow {
	// MARK: Workflow
	public enum State: CaseAccessible {
		case loggedOut
		case retrievingToken
		case authenticating(code: String)
		case loggedIn(token: Token, strategy: LoginStrategy)
		case discardingToken
	}

	public enum Output: Equatable, CaseAccessible {
		case loginURL(URL)
		case login(token: Token)
		case logout
		case termination
	}

	public func makeInitialState() -> State {
		switch source {
		case .empty:
			.retrievingToken
		case let .authorizationCode(code):
			.authenticating(code: code)
		}
	}

	public func workflowDidChange(from previousWorkflow: Self, state: inout State) {
		// TODO: Duplicated
		switch (previousWorkflow.source, source) {
		case let (.empty, .authorizationCode(code)):
			state = .authenticating(code: code)
		case let (.authorizationCode(previousCode), .authorizationCode(code)) where code != previousCode:
			state = .authenticating(code: code)
		default:
			break
		}
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> Settings.Screen {
		context.render(
			workflows: {
				switch state {
				case .retrievingToken:
					[tokenRetrievalWorker.asAnyWorkflow()]
				case .discardingToken:
					[tokenDiscardWorker.asAnyWorkflow()]
				case let .authenticating(code):
					[authenticationWorker(withAuthorizationCode: code).asAnyWorkflow()]
				default:
					[]
				}
			}(),
			sideEffects: state.authenticatedToken.map { token in
				[token: storeEffect(for: token)]
			}
		) { sink in
			.init(
				logIn: { sink.send(.logIn) },
				logOut: { sink.send(.logOut) },
				quit: { sink.send(.quit) },
				isLoggedIn: state ~= State.loggedIn,
				isLoggedOut: state ~= State.loggedOut
			)
		}
	}
}

// MARK: -
private extension Settings.Workflow {
	enum Action {
		case logIn
		case finishAuthentication(token: Token)
		case finishTokenRetrieval(Token?)
		case finishTokenDiscard
		case handle(Error)
		case logOut
		
		case quit
	}

	var tokenRetrievalWorker: TokenWorker<TokenService, Action> {
		.init(
			service: tokenService,
			request: .retrieve(
				success: { .finishTokenRetrieval($0) },
				failure: { .handle(.tokenError(.retrievalError($0))) }
			)
		)
	}

	var tokenDiscardWorker: TokenWorker<TokenService, Action> {
		.init(
			service: tokenService,
			request: .discard(
				completion: .finishTokenDiscard
			)
		)
	}

	func authenticationWorker(withAuthorizationCode code: String) -> AuthenticationWorker<AuthenticationService, Action> {
		.init(
			service: authenticationService,
			authorizationCode: code,
			success: { .finishAuthentication(token: $0) },
			failure: { .handle(.loginError($0)) }
		)
	}

	func storeEffect(for token: Token) -> SideEffect<Action> {
		{ [tokenService] _ in
			for await result in await tokenService.store(token).results {
				if case let .failure(error) = result {
					return .handle(.tokenError(.storageError(error)))
				}
			}
			return nil
		}
	}
}

// MARK: -
public extension Settings.Workflow.State {
	enum LoginStrategy {
		case tokenRetrieval
		case authentication
	}
}

// MARK: -
private extension Settings.Workflow.State {
	var authenticatingCode: String? {
		associatedValue(matching: Self.authenticating)
	}

	var authenticatedToken: TokenService.Token? {
		switch self {
		case let .loggedIn(token, .authentication): token
		default: nil
		}
	}
}

// MARK: -
extension Settings.Workflow.Action: WorkflowAction {
	typealias WorkflowType = Settings.Workflow<AuthenticationService, TokenService>

	// MARK: WorkflowAction
	func apply(toState state: inout WorkflowType.State) -> WorkflowType.Output? {
		switch self {
		case .logIn:
			return .loginURL(AuthenticationService.authorizationURL)
		case let .finishAuthentication(token: token):
			state = .loggedIn(token: token, strategy: .authentication)
			return .login(token: token)
		case let .finishTokenRetrieval(token?):
			state = .loggedIn(token: token, strategy: .tokenRetrieval)
			return .login(token: token)
		case .finishTokenRetrieval(nil):
			state = .loggedOut
		case .logOut:
			state = .discardingToken
		case .finishTokenDiscard:
			state = .loggedOut
			return .logout
		case .quit:
			return .termination
		case let .handle(.loginError(error)):
			print(error)
			state = .loggedOut
		case let .handle(.tokenError(error)):
			print(error)
			state = .loggedOut
		}
		return nil
	}
}

// MARK: -
private extension Settings.Workflow.Action {
	enum Error {
		case loginError(AuthenticationService.AuthenticationResult.Failure)
		case tokenError(TokenError)
	}
}

// MARK: -
private extension Settings.Workflow.Action.Error {
	enum TokenError {
		case storageError(TokenService.StorageResult.Failure)
		case retrievalError(TokenService.RetrievalResult.Failure)
	}
}
