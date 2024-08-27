// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro
import EnumKit
import Workflow
import AuthenticationServices

import struct Foundation.URL
import struct RaindropService.LoginWorker
import struct RaindropService.AuthenticationWorker
import struct RaindropService.TokenWorker
import typealias Ergo.SideEffect
import protocol RaindropService.AuthenticationSpec
import protocol RaindropService.TokenSpec

public extension Settings {
	struct Workflow<
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
	enum LoginStrategy {
		case tokenRetrieval
		case authentication
	}
}

// MARK: -
extension Settings.Workflow {
	public typealias Token = TokenService.Token

	@Init public struct Source {
		fileprivate let loginContextProvider: ASWebAuthenticationPresentationContextProviding & Sendable
	}
}

// MARK: -
extension Settings.Workflow: Workflow {
	// MARK: Workflow
	public enum State: CaseAccessible {
		case loggedOut
		case loggingIn
		case authenticating(code: String)
		case retrievingToken
		case loggedIn(token: Token, strategy: LoginStrategy)
		case loggingOut
	}

	public enum Output: Equatable, CaseAccessible {
		case login(token: Token, strategy: LoginStrategy)
		case logout
		case accountDeletionURL(URL)
		case opening
		case closing
		case termination
		case error(NSError)
	}

	public func makeInitialState() -> State {
		.retrievingToken
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> Settings.Screen {
		context.render(
			workflows: {
				switch state {
				case .loggingIn:
					[loginWorker.asAnyWorkflow()]
				case let .authenticating(code):
					[authenticationWorker(withAuthorizationCode: code).asAnyWorkflow()]
				case .retrievingToken:
					[tokenRetrievalWorker.asAnyWorkflow()]
				case .loggingOut:
					[tokenDiscardWorker.asAnyWorkflow()]
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
				deleteAccount: { sink.send(.deleteAccount) },
				open: { sink.send(.open) },
				close: { sink.send(.close) },
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
		case finishLogin(authorizationCode: String)
		case finishAuthentication(token: Token)
		case finishTokenRetrieval(Token?)
		case finishTokenDiscard
		case handle(Error)
		case logOut
		case deleteAccount
		case open
		case close
		case quit
	}

	var loginWorker: LoginWorker<AuthenticationService, Action> {
		.init(
			contextProvider: source.loginContextProvider,
			success: { .finishLogin(authorizationCode: $0) },
			failure: { .handle(.loginError($0)) }
		)
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
				success: .finishTokenDiscard,
				failure: { .handle(.tokenError(.storageError($0))) }
			)
		)
	}

	func authenticationWorker(withAuthorizationCode code: String) -> AuthenticationWorker<AuthenticationService, Action> {
		.init(
			service: authenticationService,
			authorizationCode: code,
			success: { .finishAuthentication(token: $0) },
			failure: { .handle(.authenticationError($0)) }
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
private extension Settings.Workflow.State {
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
			state = .loggingIn
		case let .finishLogin(authorizationCode: code):
			state = .authenticating(code: code)
		case let .finishAuthentication(token: token):
			state = .loggedIn(token: token, strategy: .authentication)
			return .login(token: token, strategy: .authentication)
		case let .finishTokenRetrieval(token?):
			state = .loggedIn(token: token, strategy: .tokenRetrieval)
			return .login(token: token, strategy: .tokenRetrieval)
		case .finishTokenRetrieval(nil):
			state = .loggedOut
		case .logOut:
			state = .loggingOut
		case .finishTokenDiscard:
			state = .loggedOut
			return .logout
		case .deleteAccount:
			state = .loggingOut
			return .accountDeletionURL(AuthenticationService.accountDeletionURL)
		case .open:
			return .opening
		case .close:
			return .closing
		case .quit:
			return .termination
		case .handle(.loginError), .handle(.authenticationError):
			state = .loggedOut
		case let .handle(.tokenError(error)):
			state = .loggedOut
			return .error(error as NSError)
		}
		return nil
	}
}

// MARK: -
private extension Settings.Workflow.Action {
	enum Error {
		case loginError(Swift.Error)
		case authenticationError(AuthenticationService.AuthenticationResult.Failure)
		case tokenError(TokenError)
	}
}

// MARK: -
private extension Settings.Workflow.Action.Error {
	enum TokenError: Error {
		case storageError(TokenService.StorageResult.Failure)
		case retrievalError(TokenService.RetrievalResult.Failure)
	}
}
