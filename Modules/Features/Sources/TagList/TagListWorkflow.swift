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
		var updatingTags: [Tag.ID: Int]
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
				uniqueKeysWithValues: state.updatingTags.map { id, count in
					(id.rawValue, raindropWorker(forTagWith: id, count: count).asAnyWorkflow())
				}
			)
		) { sink in
			.init(
				loadRaindrops: { sink.send(.loadRaindrops($0, count: $1)) },
				isLoadingRaindrops: state.updatingTags.keys.contains,
				finishLoadingRaindrops: { sink.send(.finishLoadingRaindrops(tagID: $0)) },
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
		
		case loadRaindrops(Tag.ID, count: Int)
		case updateRaindrops([Raindrop], tagID: Tag.ID)
		case finishLoadingRaindrops(tagID: Tag.ID)
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

	func raindropWorker(forTagWith id: Tag.ID, count: Int) -> RaindropWorker<Service, Action> {
		.init(
			service: service,
			source: .tag(name: id.rawValue),
			count: count,
			success: { .updateRaindrops($0, tagID: id) },
			failure: { .handleRaindropLoadingError($0) },
			completion: .finishLoadingRaindrops(tagID: id)
		)
	}
}

// MARK: -
private extension TagList.Workflow.State {
	mutating func update(with raindrops: [Raindrop], taggedWithTagWith id: Tag.ID) {
		tags = tags.map { tag in
			var tag = tag
			tag.raindrops = tag.id == id ? raindrops : tag.raindrops
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
		case let .loadRaindrops(tagID, tagCount):
			state.updatingTags[tagID] = tagCount
		case let .updateRaindrops(raindrops, tagID):
			state.update(with: raindrops, taggedWithTagWith: tagID)
		case let .finishLoadingRaindrops(tagID: tagID):
			state.updatingTags.removeValue(forKey: tagID)
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
