// Copyright © Fleuronic LLC. All rights reserved.

import enum Settings.Settings
import enum CollectionList.CollectionList
import enum GroupList.GroupList
import enum FilterList.FilterList
import enum TagList.TagList
import enum WorkflowContainers.Menu
import struct Foundation.URL
import struct Dewdrop.AccessToken
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Workflow.AnyWorkflow
import struct WorkflowMenuUI.AnyScreen
import class RaindropService.Service
import class Workflow.RenderContext
import protocol Workflow.Workflow
import protocol Workflow.WorkflowAction
import protocol Workflow.AnyWorkflowConvertible
import protocol WorkflowMenuUI.Screen
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
		UserContentService: RaindropSpec & GroupSpec & CollectionSpec & FilterSpec & TagSpec & Equatable> where
		AuthenticationService.AuthenticationResult.Success == TokenService.Token {
		private let tokenService: TokenService
		private let authenticationService: AuthenticationService
		private let settingsSource: Settings.Workflow<AuthenticationService, TokenService>.Source
		private let authenticatedService: (TokenService.Token) -> UserContentService
		
		public init(
			tokenService: TokenService,
			authenticationService: AuthenticationService,
			settingsSource: Settings.Workflow<AuthenticationService, TokenService> .Source,
			authenticatedService: @escaping (TokenService.Token) -> UserContentService
		) {
			self.tokenService = tokenService
			self.authenticationService = authenticationService
			self.settingsSource = settingsSource
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
extension Root.Workflow: Workflow {
	// MARK: Workflow
	public enum State: CaseAccessible {
		case needsUserContent
		case showingUserContent(service: UserContentService)
	}

	public enum Output {
		case url(URL)
		case termination
	}
	
	public func makeInitialState() -> State {
		.needsUserContent
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> Menu.Screen<AnyScreen> {
		let workflows = (state.userContentService.map(workflows) ?? []) + [settingsWorkflow]
		return .init(sections: workflows.map { $0.rendered(in: context) } )
	}
}

// MARK: -
private extension Root.Workflow {
	typealias ChildWorkflow = AnyWorkflow<Menu.Screen<AnyScreen>.Section, Action>

	enum Action: Equatable {
		case showUserContent(service: UserContentService)
		case hideUserContent

		case open(URL)
		case quit
	}

	var settingsWorkflow: ChildWorkflow {
		Settings.Workflow(
			source: settingsSource,
			authenticationService: authenticationService,
			tokenService: tokenService
		).mapRendering(section: .settings).mapOutput { output in
			switch output {
			case let .loginURL(url):.open(url)
			case let .login(token): .showUserContent(service: authenticatedService(token))
			case .logout: .hideUserContent
			case .termination: .quit
			}
		}
	}

	func workflows(for service: UserContentService) -> [ChildWorkflow] {
		[
			CollectionList.Workflow(service: service).mapRendering(section: .collectionList),
			GroupList.Workflow(service: service).mapRendering(section: .groupList),
			FilterList.Workflow(service: service).mapRendering(section: .filterList),
			TagList.Workflow(service: service).mapRendering(section: .tagList)
		].map { workflow in
			workflow.mapOutput { raindrop in
				.open(raindrop.url)
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
		case let .open(url):
			return .url(url)
		case let .showUserContent(service):
			state = .showingUserContent(service: service)
		case .hideUserContent:
			state = .needsUserContent
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
