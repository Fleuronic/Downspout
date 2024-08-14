// Copyright © Fleuronic LLC. All rights reserved.

import Workflow

import struct Raindrop.Tag
import struct Raindrop.Raindrop
import struct RaindropService.TagWorker
import struct RaindropService.RaindropWorker
import protocol RaindropService.TagSpec
import protocol RaindropService.RaindropSpec

extension TagList {
	public struct Workflow<Service: TagSpec & RaindropSpec> {
		private let service: Service
		
		public init(service: Service) {
			self.service = service
		}
	}
}

// MARK: -
extension TagList.Workflow: Workflow {
	public typealias Output = Raindrop

	public struct State {
		var tags: [Tag]
		var isLoadingTags: Bool
		var updatingTags: [String: Int]
	}

	public func makeInitialState() -> State {
		.init(
			tags: [],
			isLoadingTags: true,
			updatingTags: [:]
		)
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> TagList.Screen {
		context.render(
			workflows: state.isLoadingTags ? [tagWorker.asAnyWorkflow()] : [],
			keyedWorkflows: .init(
				uniqueKeysWithValues: state.updatingTags.map { name, count in
					(name, raindropWorker(forTagNamed: name, count: count).asAnyWorkflow())
				}
			)
		) { sink in
			.init(
				loadRaindrops: { sink.send(.loadRaindrops(tagName: $0, count: $1)) },
				isLoadingRaindrops: state.updatingTags.keys.contains,
				finishLoadingRaindrops: { sink.send(.finishLoadingRaindrops(tagName: $0)) },
				selectRaindrop: { sink.send(.openURL($0)) },
				tags: state.tags,
				loadTags: { sink.send(.loadTags) },
				isLoadingTags: state.isLoadingTags
			)
		}
	}
}

// MARK: -
private extension TagList.Workflow {
	enum Action: Equatable {
		case loadTags
		case updateTags([Tag])
		case handleTagLoadingError(Service.TagLoadResult.Failure)
		
		case loadRaindrops(tagName: String, count: Int)
		case updateRaindrops([Raindrop], tagName: String)
		case finishLoadingRaindrops(tagName: String)
		case handleRaindropLoadingError(Service.RaindropLoadResult.Failure)
		
		case openURL(Raindrop)
	}

	var tagWorker: TagWorker<Service, Action> {
		.init(
			service: service,
			success: { .updateTags($0) },
			failure: { .handleTagLoadingError($0) }
		)
	}

	func raindropWorker(forTagNamed name: String, count: Int) -> RaindropWorker<Service, Action> {
		.init(
			service: service,
			source: .tag(name: name),
			count: count,
			success: { .updateRaindrops($0, tagName: name) },
			failure: { .handleRaindropLoadingError($0) },
			completion: .finishLoadingRaindrops(tagName: name)
		)
	}
}

// MARK: -
private extension TagList.Workflow.State {
	mutating func update(with raindrops: [Raindrop], taggedWithTagNamed name: String) {
		tags = tags.map { tag in
			var tag = tag
			tag.raindrops = tag.name == name ? raindrops : tag.raindrops
			return tag
		}
	}
}

// MARK: -
extension TagList.Workflow.Action: WorkflowAction {
	typealias WorkflowType = TagList.Workflow<Service>

	// MARK: WorkflowAction
	func apply(toState state: inout WorkflowType.State) -> Raindrop? {
		switch self {
		case .loadTags:
			state.isLoadingTags = true
		case let .updateTags(tags):
			state.tags = tags
			state.isLoadingTags = false
		case let .loadRaindrops(tagName, tagCount):
			state.updatingTags[tagName] = tagCount
		case let .updateRaindrops(raindrops, tagName):
			state.update(with: raindrops, taggedWithTagNamed: tagName)
		case let .finishLoadingRaindrops(tagName: tagName):
			state.updatingTags.removeValue(forKey: tagName)
		case let .handleTagLoadingError(error):
			print(error)
		case let .handleRaindropLoadingError(error):
			print(error)
		case let .openURL(raindrop):
			return raindrop
		}
		return nil
	}
}
