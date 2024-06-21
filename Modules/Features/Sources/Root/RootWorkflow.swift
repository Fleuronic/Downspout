// Copyright © Fleuronic LLC. All rights reserved.

import Workflow
import WorkflowContainers
import WorkflowMenuUI

import enum Settings.Settings
import enum CollectionList.CollectionList
import enum GroupList.GroupList
import enum FilterList.FilterList
import enum TagList.TagList
import struct Foundation.URL
import struct Dewdrop.AccessToken
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct RaindropAPI.API
import struct RaindropDatabase.Database
import class RaindropService.Service
import protocol Ergo.WorkerOutput
import protocol EnumKit.CaseAccessible
import protocol RaindropService.AuthenticationSpec
import protocol RaindropService.CollectionSpec
import protocol RaindropService.RaindropSpec
import protocol RaindropService.FilterSpec
import protocol RaindropService.GroupSpec
import protocol RaindropService.TagSpec
import protocol RaindropService.TokenSpec

public enum Root {}

// MARK: -
extension Root {
	public struct Workflow<
		TokenService: TokenSpec,
		AuthenticationService: AuthenticationSpec,
		AuthenticatedService: RaindropSpec & GroupSpec & CollectionSpec & FilterSpec & TagSpec & Equatable> where
		AuthenticationService.AuthenticationResult.Success == TokenService.Token {
		private let tokenService: TokenService
		private let authenticationService: AuthenticationService
		private let settingsSource: Settings.Workflow<AuthenticationService, TokenService>.Source
		private let authenticatedService: (TokenService.Token) -> AuthenticatedService
		
		public init(
			tokenService: TokenService,
			authenticationService: AuthenticationService,
			settingsSource: Settings.Workflow<AuthenticationService, TokenService> .Source,
			authenticatedService: @escaping (TokenService.Token) -> AuthenticatedService
		) {
			self.tokenService = tokenService
			self.authenticationService = authenticationService
			self.settingsSource = settingsSource
			self.authenticatedService = authenticatedService
		}
	}
}

// MARK: -
extension Root.Workflow: Workflow {
	// MARK: Workflow
	public enum State: CaseAccessible {
		case unauthenticated
		case authenticated(service: AuthenticatedService)
	}

	public enum Output {
		case url(URL)
		case termination
	}
	
	public func makeInitialState() -> State {
		.unauthenticated
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> Menu.Screen<AnyScreen> {
		.init(
			sections: state.authenticatedService.map { service in
				[
					collectionListWorkflow,
					groupListWorkflow,
					filterListWorkflow,
					tagListWorkflow
				].map { section in section(service).mapOutput(action).rendered(in: context) }
			} ?? [] + [
				settingsWorkflow.mapOutput(action).rendered(in: context)
			]
		)
	}
}

// MARK: -
private extension Root.Workflow {
	typealias Section = Menu.Screen<AnyScreen>.Section
	typealias SettingsOutput = Settings.Workflow<AuthenticationService, TokenService>.Output
	
	enum Action: Equatable {
		case authenticate(AuthenticatedService)
		case deauthenticate
		case open(URL)
		case quit
	}
	
	var settingsWorkflow: AnyWorkflow<Section, SettingsOutput> {
		Settings.Workflow(
			source: settingsSource,
			authenticationService: authenticationService,
			tokenService: tokenService
		).mapRendering { screen in
			Menu.Section(
				key: "Settings",
				screen: screen.asAnyScreen()
			)
		}
	}

	func collectionListWorkflow(with service: AuthenticatedService) -> AnyWorkflow<Section, Raindrop> {
		CollectionList.Workflow(service: service).mapRendering { screen in
			Menu.Section(
				key: "CollectionList",
				screen: screen.asAnyScreen()
			)
		}
	}
	
	func groupListWorkflow(with service: AuthenticatedService) -> AnyWorkflow<Section, Raindrop> {
		GroupList.Workflow(service: service).mapRendering { screen in
			Menu.Section(
				key: "GroupList",
				screen: screen.asAnyScreen()
			)
		}
	}
	
	func filterListWorkflow(with service: AuthenticatedService) -> AnyWorkflow<Section, Raindrop> {
		FilterList.Workflow(service: service).mapRendering { screen in
			Menu.Section(
				key: "FilterList",
				screen: screen.asAnyScreen()
			)
		}
	}
	
	func tagListWorkflow(with service: AuthenticatedService) -> AnyWorkflow<Section, Raindrop> {
		TagList.Workflow(service: service).mapRendering { screen in
			Menu.Section(
				key: "TagList",
				screen: screen.asAnyScreen()
			)
		}
	}
	
	func action(for raindrop: Raindrop) -> Action { 
		.open(raindrop.url)
	}
	
	func action(for output: SettingsOutput) -> Action {
		switch output {
		case let .loginURL(url): .open(url)
		case let .login(token): .authenticate(authenticatedService(token))
		case .logout: .deauthenticate
		case .termination: .quit
		}
	}
}

// MARK: -
private extension Root.Workflow.State {
	var authenticatedService: AuthenticatedService? { associatedValue() }
}

// MARK: -
extension Root.Workflow.Action: WorkflowAction {
	typealias WorkflowType = Root.Workflow<TokenService, AuthenticationService, AuthenticatedService>

	// MARK: WorkflowAtion
	func apply(toState state: inout WorkflowType.State) -> WorkflowType.Output? {
		switch self {
		case let .open(url):
			return .url(url)
		case let .authenticate(service):
			state = .authenticated(service: service)
		case .deauthenticate:
			state = .unauthenticated
		case .quit:
			return .termination
		}
		return nil
	}
}
