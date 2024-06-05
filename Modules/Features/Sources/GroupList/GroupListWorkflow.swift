// Copyright © Fleuronic LLC. All rights reserved.

import EnumKit
import Ergo
import RaindropAPI
import Workflow

import struct Raindrop.Group
import struct Raindrop.Raindrop
import protocol RaindropService.LoadingSpec

public extension GroupList {
	struct Workflow<Service: LoadingSpec> where Service.GroupLoadingResult == Group.LoadingResult {
		private let service: Service
		
		public init(service: Service) {
			self.service = service
		}
	}
}

// MARK: -

extension GroupList.Workflow {
	enum Action: CaseAccessible, Equatable {
		case show([Group]?)
		case openURL(Raindrop)
		case updateGroups
	}
}

// MARK: -

extension GroupList.Workflow: Workflow {
	public typealias Output = Raindrop

	typealias UpdateWorker = Worker<Void, Group.LoadingResult>

	public struct State {
		var groups: [Group]
		let updateWorker: UpdateWorker
	}

	public func makeInitialState() -> State {
		let updateGroups = service.loadGroups
		return .init(
			groups: [],
			updateWorker: .ready(to: updateGroups)
		)
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> GroupList.Screen {
		context.render { (sink: Sink<Action>) in
			.init(
				groups: state.groups,
				selectRaindrop: { sink.send(.openURL($0)) },
				updateGroups: { sink.send(.updateGroups) },
				isUpdatingGroups: state.isUpdatingGroups
			)
		} running: {
			state.updateWorker.mapSuccess(Action.show)
		}
	}
}

// MARK: -

private extension GroupList.Workflow.State {
	var isUpdatingGroups: Bool {
		updateWorker.isWorking
	}

	func logError() {
		if let (error, dismissHandler) = updateWorker.errorContext {
			print(error)
			dismissHandler()
		}
	}
}

// MARK: -

extension GroupList.Workflow.Action: WorkflowAction {
	typealias WorkflowType = GroupList.Workflow<Service>

	func apply(toState state: inout WorkflowType.State) -> Raindrop? {
		switch self {
		case let .show(groups?):
			state.groups = groups
		case let .openURL(raindrop):
			return raindrop
		case .updateGroups:
			state.updateWorker.start()
		default:
			state.logError()
		}
		return nil
	}
}
