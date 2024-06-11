// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Tag
import struct RaindropAPI.API
import struct RaindropService.TagWorker
import struct RaindropService.RaindropWorker
import class Workflow.RenderContext
import protocol Workflow.Workflow
import protocol Workflow.WorkflowAction
import protocol RaindropService.TagSpec
import protocol RaindropService.RaindropSpec

public extension TagList {
	struct Workflow<Service: TagSpec & RaindropSpec> where 
		Service.TagLoadingResult == Tag.LoadingResult,
		Service.RaindropLoadingResult == Raindrop.LoadingResult {
		private let service: Service
		
		public init(service: Service) {
			self.service = service
		}
	}
}

// MARK: -
extension TagList.Workflow {
	enum Action: Equatable {
		case updateTags
		case showTags([Tag])
		case updateRaindrops(tagName: String)
		case showRaindrops([Raindrop], tagName: String)
		case logTagError(Tag.LoadingResult.Error)
		case logRaindropError(Raindrop.LoadingResult.Error)
		case openURL(Raindrop)
	}
}

// MARK: -
extension TagList.Workflow: Workflow {
	public typealias Output = Raindrop

	public struct State {
		var tags: [Tag]
		var isUpdatingTags: Bool
		var updatingTagNames: Set<String>
	}

	public func makeInitialState() -> State {
		.init(
			tags: [],
			isUpdatingTags: false,
			updatingTagNames: []
		)
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> TagList.Screen {
		context.render(
			workflows: state.isUpdatingTags ? [tagWorker.asAnyWorkflow()] : [],
			keyedWorkflows: .init(
				uniqueKeysWithValues: state.updatingTagNames.map { name in
					(name, raindropWorker(forTagNamed: name).asAnyWorkflow())
				}
			)
		) { sink in
			.init(
				tags: state.tags,
				updateTags: { sink.send(.updateTags) },
				updateRaindrops: { sink.send(.updateRaindrops(tagName: $0)) },
				isUpdatingTags: state.isUpdatingTags,
				isUpdatingRaindrops: state.updatingTagNames.contains,
				selectRaindrop: { sink.send(.openURL($0)) }
			)
		}
	}
}

// MARK: -
private extension TagList.Workflow {
	var tagWorker: TagWorker<Service, Action> {
		.init(
			service: service,
			success: Action.showTags,
			failure: Action.logTagError
		)
	}

	func raindropWorker(forTagNamed name: String) -> RaindropWorker<Service, Action> {
		.init(
			service: service,
			source: .tag(name: name),
			success: { Action.showRaindrops($0, tagName: name) },
			failure: Action.logTagError
		)
	}
}

// MARK: -
private extension TagList.Workflow.State {
	mutating func update(with raindrops: [Raindrop], taggedByTagNamed name: String) {
		tags = tags.map { tag in
			.init(
				name: tag.name,
				raindropCount: tag.raindropCount,
				loadedRaindrops: tag.name == name ? raindrops : tag.loadedRaindrops
			)
		}
	}

	mutating func setUpdating(_ updating: Bool, forTagNamed name: String) {
		if updating {
			updatingTagNames.insert(name)
		} else {
			updatingTagNames.remove(name)
		}
	}
}

// MARK: -
extension TagList.Workflow.Action: WorkflowAction {
	typealias WorkflowType = TagList.Workflow<Service>

	func apply(toState state: inout WorkflowType.State) -> Raindrop? {
		switch self {
		case .updateTags:
			state.isUpdatingTags = true
		case let .showTags(tags):
			state.tags = tags
			state.isUpdatingTags = false
		case let .updateRaindrops(tagName):
			state.setUpdating(true, forTagNamed: tagName)
		case let .showRaindrops(raindrops, tagName):
			state.update(with: raindrops, taggedByTagNamed: tagName)
			state.setUpdating(false, forTagNamed: tagName)
		case let .logTagError(error):
			print(error)
		case let .logRaindropError(error):
			print(error)
		case let .openURL(raindrop):
			return raindrop
		}
		return nil
	}
}
