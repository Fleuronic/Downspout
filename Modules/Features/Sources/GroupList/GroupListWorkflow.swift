// Copyright © Fleuronic LLC. All rights reserved.

import Workflow

import struct Raindrop.Group
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct RaindropService.GroupWorker
import struct RaindropService.RaindropLoadWorker
import protocol RaindropService.GroupSpec
import protocol RaindropService.RaindropSpec

extension GroupList {
	public struct Workflow<Service: GroupSpec & RaindropSpec> {
		private let service: Service
		
		public init(service: Service) {
			self.service = service
		}
	}
}

// MARK: -
extension GroupList.Workflow: Workflow {
	// MARK: Workflow
	public typealias Output = Raindrop

	public struct State {
		var groups: [Group]
		var isLoadingGroups: Bool
		var loadingCollections: [Collection.ID: Int]
	}

	public func makeInitialState() -> State {
		.init(
			groups: [],
			isLoadingGroups: true,
			loadingCollections: [:]
		)
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> GroupList.Screen {
		context.render(
			workflows: state.isLoadingGroups ? [groupWorker.asAnyWorkflow()] : [],
			keyedWorkflows: .init(
				uniqueKeysWithValues: state.loadingCollections.map { id, count in
					(id.description, raindropLoadWorker(forCollectionWith: id, count: count).asAnyWorkflow())
				}
			)
		) { sink in
			.init(
				loadRaindrops: { sink.send(.loadRaindrops($0, count: $1)) },
				isLoadingRaindrops: state.loadingCollections.keys.contains,
				finishLoadingRaindrops: { sink.send(.finishLoadingRaindrops(collectionID: $0)) },
				selectRaindrop: { sink.send(.openURL($0)) },
				groups: state.groups,
				loadGroups: { sink.send(.loadGroups) },
				isLoadingGroups: state.isLoadingGroups
			)
		}
	}
}

// MARK: -
private extension GroupList.Workflow {
	enum Action {
		case loadGroups
		case updateGroups([Group])
		case finishLoadingGroups
		case handleGroupLoadingError(Service.GroupLoadResult.Failure)
		
		case loadRaindrops(Collection.ID, count: Int)
		case updateRaindrops([Raindrop], collectionID: Collection.ID)
		case finishLoadingRaindrops(collectionID: Collection.ID)
		case handleRaindropLoadingError(Service.RaindropLoadResult.Failure, collectionID: Collection.ID)

		case openURL(Raindrop)
	}

	var groupWorker: GroupWorker<Service, Action> {
		.init(
			service: service,
			success: { .updateGroups($0) },
			failure: { .handleGroupLoadingError($0) },
			completion: .finishLoadingGroups
		)
	}

	func raindropLoadWorker(forCollectionWith id: Collection.ID, count: Int) -> RaindropLoadWorker<Service, Action> {
		.init(
			service: service,
			source: .collection(id, count: count),
			success: { .updateRaindrops($0, collectionID: id) },
			failure: { .handleRaindropLoadingError($0, collectionID: id) },
			completion: .finishLoadingRaindrops(collectionID: id)
		)
	}
}

// MARK: -
private extension GroupList.Workflow.State {
	mutating func update(with raindrops: [Raindrop], inCollectionWith collectionID: Collection.ID) {
		groups = groups.map { group in
			var group = group
			group.collections = group.collections.updated(with: raindrops, for: collectionID)
			return group
		}
	}
}

// MARK: -
extension GroupList.Workflow.Action: WorkflowAction {
	typealias WorkflowType = GroupList.Workflow<Service>

	// MARK: WorkflowAction
	func apply(toState state: inout WorkflowType.State) -> Raindrop? {
		switch self {
		case .loadGroups:
			state.isLoadingGroups = true
		case let .updateGroups(groups):
			state.groups = groups
		case .finishLoadingGroups, .handleGroupLoadingError:
			state.isLoadingGroups = false

		case let .loadRaindrops(collectionID, count):
			state.loadingCollections[collectionID] = count
		case let .updateRaindrops(raindrops, collectionID):
			state.update(with: raindrops, inCollectionWith: collectionID)
		case let .finishLoadingRaindrops(collectionID), let .handleRaindropLoadingError(_, collectionID):
			state.loadingCollections.removeValue(forKey: collectionID)

		case let .openURL(raindrop):
			return raindrop
		}
		return nil
	}
}
