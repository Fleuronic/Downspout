// Copyright © Fleuronic LLC. All rights reserved.

import Workflow

import struct Raindrop.Collection
import struct Raindrop.Raindrop
import struct RaindropService.CollectionWorker
import struct RaindropService.RaindropWorker
import protocol RaindropService.CollectionSpec
import protocol RaindropService.RaindropSpec

extension CollectionList {
	public struct Workflow<Service: CollectionSpec & RaindropSpec> {
		private let service: Service
		
		public init(service: Service) {
			self.service = service
		}
	}
}

// MARK: -
extension CollectionList.Workflow: Workflow {
	// MARK: Workflow
	public typealias Output = Raindrop

	public struct State {
		var collections: [Collection]
		var isLoadingCollections: Bool
		var loadingCollections: [Collection.ID: Int]
	}

	public func makeInitialState() -> State {
		.init(
			collections: [],
			isLoadingCollections: true,
			loadingCollections: [:]
		)
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> CollectionList.Screen {
		context.render(
			workflows: state.isLoadingCollections ? [collectionWorker.asAnyWorkflow()] : [],
			keyedWorkflows: .init(
				uniqueKeysWithValues: state.loadingCollections.map { id, count in
					(id.description, raindropWorker(forCollectionWith: id, count: count).asAnyWorkflow())
				}
			)
		) { sink in
			.init(
				loadRaindrops: { sink.send(.loadRaindrops($0, count: $1)) },
				isLoadingRaindrops: state.loadingCollections.keys.contains,
				finishLoadingRaindrops: { sink.send(.finishLoadingRaindrops(collectionID: $0)) },
				selectRaindrop: { sink.send(.openURL($0)) },
				collections: state.collections,
				loadCollections: { sink.send(.loadCollections) },
				isLoadingCollections: state.isLoadingCollections
			)
		}
	}
}

// MARK: -
private extension CollectionList.Workflow {
	enum Action: Equatable, Sendable {
		case loadCollections
		case updateCollections([Collection])
		case finishLoadingCollections
		case handleCollectionLoadingError(Service.CollectionLoadResult.Failure)
		
		case loadRaindrops(Collection.ID, count: Int)
		case updateRaindrops([Raindrop], collectionID: Collection.ID)
		case finishLoadingRaindrops(collectionID: Collection.ID)
		case handleRaindropLoadingError(Service.RaindropLoadResult.Failure)
		
		case openURL(Raindrop)
	}

	var collectionWorker: CollectionWorker<Service, Action> {
		.init(
			service: service,
			success: { .updateCollections($0) },
			failure: { .handleCollectionLoadingError($0) },
			completion: .finishLoadingCollections
		)
	}

	func raindropWorker(forCollectionWith id: Collection.ID, count: Int) -> RaindropWorker<Service, Action> {
		.init(
			service: service,
			source: .collection(id),
			count: count,
			success: { .updateRaindrops($0, collectionID: id) },
			failure: { .handleRaindropLoadingError($0) },
			completion: .finishLoadingRaindrops(collectionID: id)
		)
	}
}

// MARK: -
private extension CollectionList.Workflow.State {
	mutating func update(with raindrops: [Raindrop], inCollectionWith collectionID: Collection.ID) {
		collections = collections.map { collection in
			.init(
				id: collection.id,
				parentID: collection.parentID,
				title: collection.title,
				count: collection.count,
				isShared: collection.isShared,
				sortIndex: collection.sortIndex,
				groupID: collection.groupID,
				collections: collection.collections,
				raindrops: collection.id == collectionID ? raindrops : collection.raindrops
			)
		}
	}
}

// MARK: -
extension CollectionList.Workflow.Action: WorkflowAction {
	typealias WorkflowType = CollectionList.Workflow<Service>

	// MARK: WorkflowAction
	func apply(toState state: inout WorkflowType.State) -> Raindrop? {
		switch self {
		case .loadCollections:
			state.isLoadingCollections = true
		case let .updateCollections(collections):
			state.collections = collections
		case .finishLoadingCollections:
			state.isLoadingCollections = false
		case let .loadRaindrops(collectionID, count):
			state.loadingCollections[collectionID] = count
		case let .updateRaindrops(raindrops, collectionID):
			state.update(with: raindrops, inCollectionWith: collectionID)
		case let .finishLoadingRaindrops(collectionID: collectionID):
			state.loadingCollections.removeValue(forKey: collectionID)
		case let .handleCollectionLoadingError(error):
			print(error)
		case let .handleRaindropLoadingError(error):
			print(error)
		case let .openURL(raindrop):
			return raindrop
		}
		return nil
	}
}
