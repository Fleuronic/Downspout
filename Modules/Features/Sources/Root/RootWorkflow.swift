// Copyright © Fleuronic LLC. All rights reserved.

import Ergo
import EnumKit
import Workflow
import WorkflowContainers
import WorkflowMenuUI

import enum Settings.Settings
import enum CollectionList.CollectionList
import enum GroupList.GroupList
import enum FilterList.FilterList
import enum TagList.TagList
import struct Dewdrop.AccessToken
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct RaindropAPI.API
import struct RaindropDatabase.Database
import class RaindropService.Service
import struct Foundation.URL
import protocol RaindropService.AuthenticationSpec
import protocol RaindropService.CollectionSpec
import protocol RaindropService.RaindropSpec
import protocol RaindropService.FilterSpec
import protocol RaindropService.GroupSpec
import protocol RaindropService.TagSpec
import protocol RaindropService.TokenSpec

public enum Root {}

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
extension Root.Workflow {
	enum Action: Equatable {
		case authenticate(AuthenticatedService)
		case deauthenticate
		case open(URL)
		case quit
	}
}

// MARK: -
extension Root.Workflow: Workflow {
	public enum Output {
		case url(URL)
		case termination
	}
	
	public enum State: CaseAccessible {
		case unauthenticated
		case authenticated(service: AuthenticatedService)
	}

	public func makeInitialState() -> State {
		.unauthenticated
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> Menu.Screen<AnyScreen> {
		let authenticatedSections = state.authenticatedService.map { api in
			[
				CollectionList.Workflow(service: api).mapRendering { screen in
					Menu.Section(
						key: "CollectionList",
						screen: screen.asAnyScreen()
					)
				},
				GroupList.Workflow(service: api).mapRendering { screen in
					Menu.Section(
						key: "GroupList",
						screen: screen.asAnyScreen()
					)
				},
				FilterList.Workflow(service: api).mapRendering { screen in
					Menu.Section(
						key: "FilterList",
						screen: screen.asAnyScreen()
					)
				},
				TagList.Workflow(service: api).mapRendering { screen in
					Menu.Section(
						key: "TagList",
						screen: screen.asAnyScreen()
					)
				}
			].map { workflow in
				workflow.mapOutput { raindrop in
					Action.open(raindrop.url)
				}.rendered(in: context)
			}
		} ?? []

		let settingsSection = Settings.Workflow(
			source: settingsSource,
			authenticationService: authenticationService,
			tokenService: tokenService
		).mapRendering { screen in
			Menu.Section(
				key: "Settings",
				screen: screen.asAnyScreen()
			)
		}.mapOutput { output in
			switch output {
			case let .loginURL(url):
				Action.open(url)
			case let .login(token):
				Action.authenticate(authenticatedService(token))
			case .logout:
				Action.deauthenticate
			case .termination:
				Action.quit
			}
		}.rendered(in: context)

		return .init(
			sections: authenticatedSections + [settingsSection]
		)
	}
}

private extension Root.Workflow.State {
	var authenticatedService: AuthenticatedService? { associatedValue() }
}

// MARK: -
extension Root.Workflow.Action: WorkflowAction {
	typealias WorkflowType = Root.Workflow<TokenService, AuthenticationService, AuthenticatedService>

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
