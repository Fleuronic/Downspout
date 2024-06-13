// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Collection
import struct Raindrop.Raindrop
import struct RaindropAPI.API
import struct RaindropService.CollectionWorker
import struct RaindropService.RaindropWorker
import class Workflow.RenderContext
import protocol Workflow.Workflow
import protocol Workflow.WorkflowAction
import protocol RaindropService.CollectionSpec
import protocol RaindropService.RaindropSpec

public extension CollectionList {
	struct Workflow<Service: CollectionSpec & RaindropSpec> where
		Service.CollectionLoadingResult == Collection.LoadingResult,
		Service.RaindropLoadingResult == Raindrop.LoadingResult {
		private let service: Service
		
		public init(service: Service) {
			self.service = service
		}
	}
}

// MARK: -
extension CollectionList.Workflow {
	enum Action: Equatable {
		case updateCollections
		case showCollections([Collection])
		case updateRaindrops(Collection.ID, count: Int)
		case showRaindrops([Raindrop], collectionID: Collection.ID)
		case logCollectionError(Collection.LoadingResult.Error)
		case logRaindropError(Raindrop.LoadingResult.Error)
		case openURL(Raindrop)
	}
}

// MARK: -
extension CollectionList.Workflow: Workflow {
	public typealias Output = Raindrop

	public struct State {
		var collections: [Collection]
		var isUpdatingCollections: Bool
		var updatingCollections: [Collection.ID: Int]
	}

	public func makeInitialState() -> State {
		.init(
			collections: [],
			isUpdatingCollections: false,
			updatingCollections: [:]
		)
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> CollectionList.Screen {
		context.render(
			workflows: state.isUpdatingCollections ? [collectionWorker.asAnyWorkflow()] : [],
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
				collections: state.collections,
				updateCollections: { sink.send(.updateCollections) },
				isUpdatingCollections: state.isUpdatingCollections
			)
		}
	}
}

// MARK: -
private extension CollectionList.Workflow {
	var collectionWorker: CollectionWorker<Service, Action> {
		.init(
			service: service,
			success: Action.showCollections,
			failure: Action.logCollectionError
		)
	}

	func raindropWorker(forCollectionWith id: Collection.ID, count: Int) -> RaindropWorker<Service, Action> {
		.init(
			service: service,
			source: .collection(id),
			count: count,
			success: { Action.showRaindrops($0, collectionID: id) },
			failure: Action.logRaindropError
		)
	}
}

// MARK: -
private extension CollectionList.Workflow.State {
	mutating func update(with raindrops: [Raindrop], inCollectionWith collectionID: Collection.ID) {
		collections = collections.map { collection in
			.init(
				id: collection.id,
				title: collection.title,
				count: collection.count,
				isShared: false, 
				collections: [],
				loadedRaindrops: collection.id == collectionID ? raindrops : collection.loadedRaindrops
			)
		}
	}
}

// MARK: -
extension CollectionList.Workflow.Action: WorkflowAction {
	typealias WorkflowType = CollectionList.Workflow<Service>

	func apply(toState state: inout WorkflowType.State) -> Raindrop? {
		switch self {
		case .updateCollections:
			state.isUpdatingCollections = true
		case let .showCollections(Collections):
			state.collections = Collections
			state.isUpdatingCollections = false
		case let .updateRaindrops(collectionID, count):
			state.updatingCollections[collectionID] = count
		case let .showRaindrops(raindrops, collectionID):
			state.update(with: raindrops, inCollectionWith: collectionID)
			state.updatingCollections.removeValue(forKey: collectionID)
		case let .logCollectionError(error), let .logRaindropError(error):
			print(error)
		case let .openURL(raindrop):
			return raindrop
		}
		return nil
	}
}
