// Copyright © Fleuronic LLC. All rights reserved.

import Ergo
import EnumKit

import enum Settings.Settings
import enum CollectionList.CollectionList
import struct Dewdrop.AccessToken
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct RaindropAPI.API
import class Workflow.RenderContext
import struct Workflow.AnyWorkflow
import protocol Workflow.Workflow
import protocol Workflow.WorkflowAction
import protocol RaindropService.AuthenticationSpec
import protocol RaindropService.CollectionSpec
import protocol RaindropService.RaindropSpec
import struct Foundation.URL
import WorkflowContainers
import WorkflowMenuUI

public enum Root {}

public extension Root {
	struct Workflow<Service: RaindropSpec & CollectionSpec, AuthenticationService: AuthenticationSpec> where
		Service.RaindropLoadingResult == Raindrop.LoadingResult,
		Service.CollectionLoadingResult == Collection.LoadingResult,
		AuthenticationService.TokenResult == AccessToken.Result {
		private let service: Service
		private let authenticationService: AuthenticationService
		public init(
			service: Service,
			authenticationService: AuthenticationService
		) {
			self.service = service
			self.authenticationService = authenticationService
		}
	}
}

// MARK: -
extension Root.Workflow {
	enum Action: Equatable {
		case handleCollectionListOutput(CollectionList.Workflow<Service>.Output)
		case handleSettingsOutput(Settings.Workflow<AuthenticationService>.Output)
	}
}

// MARK: -
extension Root.Workflow: Workflow {
	public enum State {
		case loggedIn
		case loggedOut
	}

	public enum Output {
		case collectionList(Raindrop)
		case settings(Settings.Workflow<AuthenticationService>.Output)
	}

	public func makeInitialState() -> State {
		.loggedOut
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> Menu.Screen<AnyScreen> {
		.init(
			sections: [
				CollectionList.Workflow(
					service: service
				).mapOutput(Action.handleCollectionListOutput).rendered(in: context),
				Settings.Workflow(
					source: .accessToken,
					service: authenticationService
				).mapOutput(Action.handleSettingsOutput).rendered(in: context)
			]
		)
	}
}

// MARK: -
extension Root.Workflow.Action: WorkflowAction {
	typealias WorkflowType = Root.Workflow<Service, AuthenticationService>

	func apply(toState state: inout WorkflowType.State) -> WorkflowType.Output? {
		switch self {
		case let .handleCollectionListOutput(output): .collectionList(output)
		case let .handleSettingsOutput(output): .settings(output)
		}

	}
}
