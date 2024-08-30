// Copyright © Fleuronic LLC. All rights reserved.

import Workflow

import struct Raindrop.Tag
import struct Raindrop.Raindrop
import struct RaindropService.TagWorker
import struct RaindropService.RaindropLoadWorker
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
					(id.rawValue, raindropLoadWorker(forTagWith: id, count: count).asAnyWorkflow())
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
		case finishLoadingTags
		case handleTagLoadingError(Service.TagLoadResult.Failure)
		
		case loadRaindrops(Tag.ID, count: Int)
		case updateRaindrops([Raindrop], tagID: Tag.ID)
		case finishLoadingRaindrops(tagID: Tag.ID)
		case handleRaindropLoadingError(Service.RaindropLoadResult.Failure, tagID: Tag.ID)

		case openURL(Raindrop)
	}

	var tagWorker: TagWorker<Service, Action> {
		.init(
			service: service,
			success: { .updateTags($0) },
			failure: { .handleTagLoadingError($0) },
			completion: .finishLoadingTags
		)
	}

	func raindropLoadWorker(forTagWith id: Tag.ID, count: Int) -> RaindropLoadWorker<Service, Action> {
		.init(
			service: service,
			source: .tag(name: id.rawValue, count: count),
			success: { .updateRaindrops($0, tagID: id) },
			failure: { .handleRaindropLoadingError($0, tagID: id) },
			completion: .finishLoadingRaindrops(tagID: id)
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
		case .finishLoadingTags, .handleTagLoadingError:
			state.isLoadingTags = false

		case let .loadRaindrops(tagID, tagCount):
			state.updatingTags[tagID] = tagCount
		case let .updateRaindrops(raindrops, tagID):
			state.update(with: raindrops, taggedWithTagNamed: tagID.rawValue)
		case let .finishLoadingRaindrops(tagID), let .handleRaindropLoadingError(_, tagID):
			state.updatingTags.removeValue(forKey: tagID)

		case let .openURL(raindrop):
			return raindrop
		}

		return nil
	}
}
