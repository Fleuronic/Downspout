// Copyright © Fleuronic LLC. All rights reserved.

import EnumKit
import Ergo
import RaindropAPI
import Workflow

import struct Raindrop.Group
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct RaindropService.GroupWorker
import struct RaindropService.RaindropWorker
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
		case updateRaindrops(Collection.ID)
		case showRaindrops([Raindrop], Collection.ID)
		case hideCollection(Collection.ID)
		case openURL(Raindrop)
		case logGroupError(Group.LoadingResult.Error)
		case logRaindropError(Raindrop.LoadingResult.Error)
	}
}

// MARK: -

extension GroupList.Workflow: Workflow {
	public typealias Output = Raindrop

	public struct State {
		var groups: [Group]
		var isUpdatingGroups: Bool
		var updatingCollectionIDs: Set<Collection.ID>
	}

	public func makeInitialState() -> State {
		.init(
			groups: [],
			isUpdatingGroups: false,
			updatingCollectionIDs: []
		)
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> GroupList.Screen {
		let groupWorkflows = state.isUpdatingGroups ? [groupWorker.asAnyWorkflow()] : []
		let raindropWorkflows = Dictionary(
			uniqueKeysWithValues: state.updatingCollectionIDs.map { id in
				(id.description, raindropWorker(forCollectionWith: id).asAnyWorkflow())
			}
		)

		return context.render(
			workflows: groupWorkflows,
			keyedWorkflows: raindropWorkflows
		) { sink in
			.init(
				groups: state.groups,
				selectRaindrop: { sink.send(.openURL($0)) },
				updateGroups: { sink.send(.updateGroups) },
				updateRaindrops: { sink.send(.updateRaindrops($0)) },
				isUpdatingGroups: state.isUpdatingGroups,
				isUpdatingRaindrops: state.updatingCollectionIDs.contains
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

	func raindropWorker(forCollectionWith id: Collection.ID) -> RaindropWorker<Service, Action> {
		.init(
			service: service,
			collectionID: id,
			success: Action.showRaindrops,
			failure: Action.logRaindropError
		)
	}
}

// MARK: -
private extension GroupList.Workflow.State {
	mutating func update(with raindrops: [Raindrop]) {
		guard let collectionID = raindrops.first?.collectionID else { return }

		groups = groups.map { group in
			.init(
				title: group.title,
				collections: group.collections.updated(with: raindrops, for: collectionID)
			)
		}
	}

	mutating func setUpdating(_ updating: Bool, forCollectionWith id: Collection.ID) {
		if updating {
			updatingCollectionIDs.insert(id)
		} else {
			updatingCollectionIDs.remove(id)
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
		case let .updateRaindrops(collectionID):
			state.setUpdating(true, forCollectionWith: collectionID)
		case let .showRaindrops(raindrops, collectionID):
			state.update(with: raindrops)
			state.setUpdating(false, forCollectionWith: collectionID)
		case let .hideCollection(id):
			state.setUpdating(false, forCollectionWith: id)
		case let .openURL(raindrop):
			return raindrop
		case let .logGroupError(error), let .logRaindropError(error):
			print(error)
		}
		return nil
	}
}

// MARK: -
private extension [Collection] {
	func updated(with raindrops: [Raindrop], for id: Collection.ID) -> [Collection] {
		map { collection in
			.init(
				id: collection.id,
				title: collection.title,
				count: collection.count,
				collections: collection.collections.updated(with: raindrops, for: id),
				loadedRaindrops: collection.id == id ? raindrops : collection.loadedRaindrops
			)
		}
	}
}
