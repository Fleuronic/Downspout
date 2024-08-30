// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro
import Workflow

import struct Raindrop.Collection
import struct Raindrop.Raindrop
import struct RaindropService.CollectionWorker
import struct RaindropService.RaindropLoadWorker
import struct RaindropService.RaindropAddWorker
import struct Foundation.URL
import protocol RaindropService.CollectionSpec
import protocol RaindropService.RaindropSpec
import protocol RaindropService.AddSpec

extension CollectionList {
	public struct Workflow<Service: CollectionSpec & RaindropSpec & AddSpec> {
		private let source: Source
		private let service: Service
		
		public init(
			source: Source,
			service: Service
		) {
			self.source = source
			self.service = service
		}
	}
}

// MARK: -
extension CollectionList.Workflow {
	@Init public struct Source {
		fileprivate let event: Event
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
		var addingURLs: Set<URL>
	}

	public func makeInitialState() -> State {
		.init(
			collections: [],
			isLoadingCollections: true,
			loadingCollections: [:],
			addingURLs: []
		)
	}

	public func workflowDidChange(from previousWorkflow: Self, state: inout State) {
		if case let .addRaindrop(url) = source.event {
			state.addingURLs.insert(url)
		}
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> CollectionList.Screen {
		context.render(
			workflows: state.isLoadingCollections ? [collectionWorker.asAnyWorkflow()] : [],
			keyedWorkflows: .init(
				uniqueKeysWithValues: state.loadingCollections.map { id, count in
					(id.description, raindropLoadWorker(forCollectionWith: id, count: count).asAnyWorkflow())
				} + state.addingURLs.map { url in
					(url.absoluteString, raindropAddWorker(for: url).asAnyWorkflow())
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
		case handleRaindropLoadingError(Service.RaindropLoadResult.Failure, collectionID: Collection.ID)

		case addRaindrop(url: URL)
		case finishAddingRaindrop(url: URL)
		case handleRaindropAddError(Service.RaindropAddResult.Failure, url: URL)

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

	func raindropLoadWorker(forCollectionWith id: Collection.ID, count: Int) -> RaindropLoadWorker<Service, Action> {
		.init(
			service: service,
			source: .collection(id, count: count),
			success: { .updateRaindrops($0, collectionID: id) },
			failure: { .handleRaindropLoadingError($0, collectionID: id) },
			completion: .finishLoadingRaindrops(collectionID: id)
		)
	}

		func raindropAddWorker(for url: URL) -> RaindropAddWorker<Service, Action> {
			.init(
				service: service,
				url: url,
				success: .finishAddingRaindrop(url: url),
				failure: { .handleRaindropAddError($0, url: url) }
			)
		}
}

// MARK: -
public extension CollectionList.Workflow.Source {
	enum Event {
		case view
		case addRaindrop(url: URL)
	}
}

// MARK: -
private extension CollectionList.Workflow.State {
	mutating func update(with raindrops: [Raindrop], inCollectionWith collectionID: Collection.ID) {
		collections = collections.map { collection in
			var collection = collection
			collection.raindrops = collection.id == collectionID ? raindrops : collection.raindrops
			return collection
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
		case .finishLoadingCollections, .handleCollectionLoadingError:
			state.isLoadingCollections = false

		case let .loadRaindrops(collectionID, count):
			state.loadingCollections[collectionID] = count
		case let .updateRaindrops(raindrops, collectionID):
			state.update(with: raindrops, inCollectionWith: collectionID)
		case let .finishLoadingRaindrops(collectionID), let .handleRaindropLoadingError(_, collectionID):
			state.loadingCollections.removeValue(forKey: collectionID)

		case let .addRaindrop(url: url):
			state.addingURLs.insert(url)
		case let .finishAddingRaindrop(url):
			state.addingURLs.remove(url)
			state.isLoadingCollections = true
		case let .handleRaindropAddError(_, url: url):
			state.addingURLs.remove(url)

		case let .openURL(raindrop):
			return raindrop
		}

		return nil
	}
}
