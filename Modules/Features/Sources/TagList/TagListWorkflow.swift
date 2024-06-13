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
		case updateRaindrops(tagName: String, count: Int)
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
		var updatingTags: [String: Int]
	}

	public func makeInitialState() -> State {
		.init(
			tags: [],
			isUpdatingTags: false,
			updatingTags: [:]
		)
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> TagList.Screen {
		context.render(
			workflows: state.isUpdatingTags ? [tagWorker.asAnyWorkflow()] : [],
			keyedWorkflows: .init(
				uniqueKeysWithValues: state.updatingTags.map { name, count in
					(name, raindropWorker(forTagNamed: name, count: count).asAnyWorkflow())
				}
			)
		) { sink in
			.init(
				updateRaindrops: { sink.send(.updateRaindrops(tagName: $0, count: $1)) },
				isUpdatingRaindrops: state.updatingTags.keys.contains,
				selectRaindrop: { sink.send(.openURL($0)) },
				tags: state.tags,
				updateTags: { sink.send(.updateTags) },
				isUpdatingTags: state.isUpdatingTags
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

	func raindropWorker(forTagNamed name: String, count: Int) -> RaindropWorker<Service, Action> {
		.init(
			service: service,
			source: .tag(name: name),
			count: count,
			success: { Action.showRaindrops($0, tagName: name) },
			failure: Action.logTagError
		)
	}
}

// MARK: -
private extension TagList.Workflow.State {
	mutating func update(with raindrops: [Raindrop], taggedWithTagNamed name: String) {
		tags = tags.map { tag in
			.init(
				name: tag.name,
				raindropCount: tag.raindropCount,
				loadedRaindrops: tag.name == name ? raindrops : tag.loadedRaindrops
			)
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
		case let .updateRaindrops(tagName, tagCount):
			state.updatingTags[tagName] = tagCount
		case let .showRaindrops(raindrops, tagName):
			state.update(with: raindrops, taggedWithTagNamed: tagName)
			state.updatingTags.removeValue(forKey: tagName)
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
