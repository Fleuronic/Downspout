// Copyright © Fleuronic LLC. All rights reserved.

import EnumKit
import Ergo
import RaindropAPI
import Workflow

import struct Raindrop.Tag
import struct Raindrop.Raindrop
import protocol RaindropService.TagSpec

public extension TagList {
	struct Workflow<Service: TagSpec> where Service.TagLoadingResult == Tag.LoadingResult {
		private let service: Service
		
		public init(service: Service) {
			self.service = service
		}
	}
}

// MARK: -
extension TagList.Workflow {
	enum Action: CaseAccessible, Equatable {
		case show([Tag]?)
		case openURL(Raindrop)
		case updateTags
	}
}

// MARK: -
extension TagList.Workflow: Workflow {
	public typealias Output = Raindrop

	typealias UpdateWorker = Worker<Void, Tag.LoadingResult>

	public struct State {
		var tags: [Tag]
		let updateWorker: UpdateWorker
	}

	public func makeInitialState() -> State {
		let updateTags = service.loadTags
		return .init(
			tags: [],
			updateWorker: .ready(to: updateTags)
		)
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> TagList.Screen {
		context.render { (sink: Sink<Action>) in
			.init(
				tags: state.tags,
				selectRaindrop: { sink.send(.openURL($0)) },
				updateTags: { sink.send(.updateTags) },
				isUpdatingTags: state.isUpdatingTags
			)
		} running: {
			state.updateWorker.mapSuccess(Action.show)
		}
	}
}

// MARK: -

private extension TagList.Workflow.State {
	var isUpdatingTags: Bool {
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

extension TagList.Workflow.Action: WorkflowAction {
	typealias WorkflowType = TagList.Workflow<Service>

	func apply(toState state: inout WorkflowType.State) -> Raindrop? {
		switch self {
		case let .show(tags?):
			state.tags = tags
		case let .openURL(raindrop):
			return raindrop
		case .updateTags:
			state.updateWorker.start()
		default:
			state.logError()
		}
		return nil
	}
}
