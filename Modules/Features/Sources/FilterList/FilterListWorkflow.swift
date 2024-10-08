// Copyright © Fleuronic LLC. All rights reserved.

import Workflow

import struct Raindrop.Raindrop
import struct Raindrop.Filter
import struct RaindropService.FilterWorker
import struct RaindropService.RaindropLoadWorker
import protocol RaindropService.FilterSpec
import protocol RaindropService.RaindropSpec

extension FilterList {
	public struct Workflow<Service: FilterSpec & RaindropSpec> {
		private let service: Service
		
		public init(service: Service) {
			self.service = service
		}
	}
}

// MARK: -
extension FilterList.Workflow: Workflow {
	// MARK: Workflow
	public typealias Output = Raindrop

	public struct State {
		var filters: [Filter]
		var isLoadingFilters: Bool
		var loadingFilters: [Filter.ID: Int]
	}

	public func makeInitialState() -> State {
		.init(
			filters: [],
			isLoadingFilters: true,
			loadingFilters: [:]
		)
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> FilterList.Screen {
		context.render(
			workflows: state.isLoadingFilters ? [filterWorker.asAnyWorkflow()] : [],
			keyedWorkflows: .init(
				uniqueKeysWithValues: state.loadingFilters.map { id, count in
					(id.rawValue, raindropLoadWorker(forFilterWith: id, count: count).asAnyWorkflow())
				}
			)
		) { sink in
			.init(
				loadRaindrops: { sink.send(.loadRaindrops($0, count: $1)) },
				isLoadingRaindrops: state.loadingFilters.keys.contains,
				finishLoadingRaindrops: { sink.send(.finishLoadingRaindrops(filterID: $0)) },
				selectRaindrop: { sink.send(.openURL($0)) },
				filters: state.filters,
				loadFilters: { sink.send(.loadFilters) },
				isLoadingFilters: state.isLoadingFilters
			)
		}
	}
}

// MARK: -
private extension FilterList.Workflow {
	enum Action: Equatable {
		case loadFilters
		case updateFilters([Filter])
		case finishLoadingFilters
		case handleFilterLoadingError(Service.FilterLoadResult.Failure)

		case loadRaindrops(Filter.ID, count: Int)
		case updateRaindrops([Raindrop], filterID: Filter.ID)
		case finishLoadingRaindrops(filterID: Filter.ID)
		case handleRaindropLoadingError(Service.RaindropLoadResult.Failure, filterID: Filter.ID)

		case openURL(Raindrop)
	}

	var filterWorker: FilterWorker<Service, Action> {
		.init(
			service: service,
			success: { .updateFilters($0) },
			failure: { .handleFilterLoadingError($0) },
			completion: .finishLoadingFilters
		)
	}

	func raindropLoadWorker(forFilterWith id: Filter.ID, count: Int) -> RaindropLoadWorker<Service, Action> {
		.init(
			service: service,
			source: .filter(id, count: count),
			success: { .updateRaindrops($0, filterID: id) },
			failure: { .handleRaindropLoadingError($0, filterID: id) },
			completion: .finishLoadingRaindrops(filterID: id)
		)
	}
}

// MARK: -
private extension FilterList.Workflow.State {
	mutating func update(with raindrops: [Raindrop], filteredByFilterWith id: Filter.ID) {
		filters = filters.map { filter in
			var filter = filter
			filter.raindrops = filter.id == id ? raindrops : filter.raindrops
			return filter
		}
	}
}

// MARK: -
extension FilterList.Workflow.Action: WorkflowAction {
	typealias WorkflowType = FilterList.Workflow<Service>

	// MARK: WorkflowAction
	func apply(toState state: inout WorkflowType.State) -> Raindrop? {
		switch self {
		case .loadFilters:
			state.isLoadingFilters = true
		case let .updateFilters(filters):
			state.filters = filters
		case .finishLoadingFilters, .handleFilterLoadingError:
			state.isLoadingFilters = false
			
		case let .loadRaindrops(filterID, filterCount):
			state.loadingFilters[filterID] = filterCount
		case let .updateRaindrops(raindrops, filterID):
			state.update(with: raindrops, filteredByFilterWith: filterID)
		case let .finishLoadingRaindrops(filterID), let .handleRaindropLoadingError(_, filterID):
			state.loadingFilters.removeValue(forKey: filterID)

		case let .openURL(raindrop):
			return raindrop
		}

		return nil
	}
}
