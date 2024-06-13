// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct RaindropAPI.API
import struct RaindropService.GroupWorker
import struct RaindropService.RaindropWorker
import class Workflow.RenderContext
import protocol Workflow.Workflow
import protocol Workflow.WorkflowAction
import protocol RaindropService.GroupSpec
import protocol RaindropService.RaindropSpec

public extension GroupList {
	struct Workflow<Service: GroupSpec & RaindropSpec> where
		Service.GroupLoadingResult == Group.LoadingResult,
		Service.RaindropLoadingResult == Raindrop.LoadingResult {
		private let service: Service
		
		public init(service: Service) {
			self.service = service
		}
	}
}

// MARK: -
extension GroupList.Workflow {
	enum Action: Equatable {
		case updateGroups
		case showGroups([Group])
		case updateRaindrops(Collection.ID, count: Int)
		case showRaindrops([Raindrop], Collection.ID)
		case logGroupError(Group.LoadingResult.Error)
		case logRaindropError(Raindrop.LoadingResult.Error)
		case openURL(Raindrop)
	}
}

// MARK: -
extension GroupList.Workflow: Workflow {
	public typealias Output = Raindrop

	public struct State {
		var groups: [Group]
		var isUpdatingGroups: Bool
		var updatingCollections: [Collection.ID: Int]
	}

	public func makeInitialState() -> State {
		.init(
			groups: [],
			isUpdatingGroups: false,
			updatingCollections: [:]
		)
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> GroupList.Screen {
		context.render(
			workflows: state.isUpdatingGroups ? [groupWorker.asAnyWorkflow()] : [],
			keyedWorkflows: .init(
				uniqueKeysWithValues: state.updatingCollections.map { id, count in
					(id.description, raindropWorker(forCollectionWith: id, count: count).asAnyWorkflow())
				}
			)
		) { sink in
			.init(
				updateRaindrops: { sink.send(.updateRaindrops($0, count: $1)) },
				isUpdatingRaindrops: state.updatingCollections.keys.contains,
				selectRaindrop: { sink.send(.openURL($0)) },
				groups: state.groups,
				updateGroups: { sink.send(.updateGroups) },
				isUpdatingGroups: state.isUpdatingGroups
			)
		}
	}
}

// MARK: -
private extension GroupList.Workflow {
	var groupWorker: GroupWorker<Service, Action> {
		.init(
			service: service,
			success: Action.showGroups,
			failure: Action.logGroupError
		)
	}

	func raindropWorker(forCollectionWith id: Collection.ID, count: Int) -> RaindropWorker<Service, Action> {
		.init(
			service: service,
			source: .collection(id),
			count: count,
			success: { Action.showRaindrops($0, id) },
			failure: Action.logRaindropError
		)
	}
}

// MARK: -
private extension GroupList.Workflow.State {
	mutating func update(with raindrops: [Raindrop], inCollectionWith collectionID: Collection.ID) {
		groups = groups.map { group in
			.init(
				title: group.title,
				collections: group.collections.updated(with: raindrops, for: collectionID)
			)
		}
	}
}

// MARK: -
extension GroupList.Workflow.Action: WorkflowAction {
	typealias WorkflowType = GroupList.Workflow<Service>

	func apply(toState state: inout WorkflowType.State) -> Raindrop? {
		switch self {
		case .updateGroups:
			state.isUpdatingGroups = true
		case let .showGroups(groups):
			state.groups = groups
			state.isUpdatingGroups = false
		case let .updateRaindrops(collectionID, count):
			state.updatingCollections[collectionID] = count
		case let .showRaindrops(raindrops, collectionID):
			state.update(with: raindrops, inCollectionWith: collectionID)
			state.updatingCollections.removeValue(forKey: collectionID)
		case let .logGroupError(error), let .logRaindropError(error):
			print(error)
		case let .openURL(raindrop):
			return raindrop
		}
		return nil
	}
}
