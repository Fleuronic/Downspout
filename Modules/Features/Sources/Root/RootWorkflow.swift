// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro
import Workflow
import WorkflowMenuUI
import WorkflowContainers

import enum CollectionList.CollectionList
import enum GroupList.GroupList
import enum FilterList.FilterList
import enum TagList.TagList
import enum Settings.Settings
import struct Foundation.URL
import struct Dewdrop.AccessToken
import struct Raindrop.Collection
import struct Raindrop.User
import class RaindropService.Service
import class Foundation.NSError
import protocol RaindropService.UserSpec
import protocol RaindropService.TokenSpec
import protocol RaindropService.AuthenticationSpec
import protocol RaindropService.RaindropSpec
import protocol RaindropService.CollectionSpec
import protocol RaindropService.GroupSpec
import protocol RaindropService.FilterSpec
import protocol RaindropService.TagSpec
import protocol RaindropService.AddSpec
import protocol EnumKit.CaseAccessible
import protocol Ergo.WorkerOutput

public enum Root {}

// MARK: -
extension Root {
	public struct Workflow<
		TokenService: TokenSpec,
		AuthenticationService: AuthenticationSpec,
		UserContentService: RaindropSpec & GroupSpec & CollectionSpec & FilterSpec & TagSpec & UserSpec & AddSpec & Equatable> where
		AuthenticationService.AuthenticationResult.Success == TokenService.Token {
		private let source: Source
		private let tokenService: TokenService
		private let authenticationService: AuthenticationService
		private let authenticatedService: (TokenService.Token) -> UserContentService

		public init(
			source: Source,
			tokenService: TokenService,
			authenticationService: AuthenticationService,
			authenticatedService: @escaping (TokenService.Token) -> UserContentService
		) {
			self.source = source
			self.tokenService = tokenService
			self.authenticationService = authenticationService
			self.authenticatedService = authenticatedService
		}
	}
}

// MARK: -
private extension Root {
	enum Section {
		case collectionList
		case groupList
		case filterList
		case tagList
		case settings
	}
}

// MARK: -
extension Root.Workflow {
	@Init public struct Source {
		fileprivate let collectionListSource: CollectionList.Workflow<UserContentService>.Source
		fileprivate let settingsSource: Settings.Workflow<TokenService, AuthenticationService, UserContentService>.Source
	}
}

// MARK: -
extension Root.Workflow: Workflow {
	// MARK: Workflow
	public enum State: CaseAccessible {
		case needsUserContent
		case showingUserContent(service: UserContentService)
	}

	public enum Output {
		case login
		case idString(String)
		case logout

		case sessionStart
		case openedURL(URL)
		case addedURL
		case sessionEnd

		case error(NSError)
		case termination
	}
	
	public func makeInitialState() -> State {
		.needsUserContent
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> Menu.Screen<AnyScreen> {
		let service = state.userContentService
		let workflows = (service.map(workflows) ?? []) + [settingsWorkflow(with: service)]
		return .init(sections: workflows.map { $0.rendered(in: context) } )
	}
}

// MARK: -
private extension Root.Workflow {
	typealias ChildWorkflow = AnyWorkflow<Menu.Screen<AnyScreen>.Section, Action>

	enum Action: Equatable {
		case showUserContent(service: UserContentService, fromLogin: Bool)
		case registerIDString(String)
		case hideUserContent

		case startSession
		case openURL(URL)
		case addURL
		case endSession

		case handle(NSError)
		case quit
	}

	func settingsWorkflow(with userService: UserContentService?) -> ChildWorkflow {
		Settings.Workflow(
			source: source.settingsSource,
			tokenService: tokenService,
			authenticationService: authenticationService,
			userService: userService
		).mapRendering(section: .settings).mapOutput { output in
			switch output {
			case let .login(token, strategy):
				.showUserContent(service: authenticatedService(token), fromLogin: strategy == .authentication)
			case let .encryptedUserIDString(string):
				.registerIDString(string)
			case .logout:
				.hideUserContent
			case let .accountDeletionURL(url):
				.openURL(url)
			case .opening:
				.startSession
			case .closing:
				.endSession
			case .termination:
				.quit
			case let .error(error):
				.handle(error)
			}
		}
	}

	func workflows(for service: UserContentService) -> [ChildWorkflow] {
		[CollectionList.Workflow(
			source: source.collectionListSource,
			service: service
		).mapRendering(section: .collectionList).mapOutput { output in
			switch output {
			case let .selectedRaindrop(raindrop):
				.openURL(raindrop.url)
			case .addedRaindrop:
				.addURL
			}
		}] + [
			GroupList.Workflow(service: service).mapRendering(section: .groupList),
			FilterList.Workflow(service: service).mapRendering(section: .filterList),
			TagList.Workflow(service: service).mapRendering(section: .tagList)
		].map { workflow in
			workflow.mapOutput { raindrop in
				.openURL(raindrop.url)
			}
		}
	}
}

// MARK: -
private extension Root.Workflow.State {
	var userContentService: UserContentService? { associatedValue() }
}

// MARK: -
extension Root.Workflow.Action: WorkflowAction {
	typealias WorkflowType = Root.Workflow<TokenService, AuthenticationService, UserContentService>

	// MARK: WorkflowAction
	func apply(toState state: inout WorkflowType.State) -> WorkflowType.Output? {
		switch self {
		case let .showUserContent(service, fromLogin):
			state = .showingUserContent(service: service)
			if fromLogin { return .login }
		case let .registerIDString(string):
			return .idString(string)
		case .hideUserContent:
			state = .needsUserContent
			return .logout

		case .startSession:
			return .sessionStart
		case let .openURL(url):
			return .openedURL(url)
		case .addURL:
			return .addedURL
		case .endSession:
			return .sessionEnd

		case let .handle(error):
			return .error(error)
		case .quit:
			return .termination
		}

		return nil
	}
}

// MARK: -
private extension AnyWorkflowConvertible where Rendering: Screen {
	func mapRendering(section: Root.Section) -> AnyWorkflow<Menu.Screen<AnyScreen>.Section, Output> {
		asAnyWorkflow().mapRendering { screen in
			.init(
				key: section,
				screen: screen.asAnyScreen()
			)
		}
	}
}
