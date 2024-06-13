// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Filter
import struct RaindropAPI.API
import struct RaindropService.FilterWorker
import struct RaindropService.RaindropWorker
import class Workflow.RenderContext
import protocol Workflow.Workflow
import protocol Workflow.WorkflowAction
import protocol RaindropService.FilterSpec
import protocol RaindropService.RaindropSpec

public extension FilterList {
	struct Workflow<Service: FilterSpec & RaindropSpec> where 
		Service.FilterLoadingResult == Filter.LoadingResult,
		Service.RaindropLoadingResult == Raindrop.LoadingResult {
		private let service: Service
		
		public init(service: Service) {
			self.service = service
		}
	}
}

// MARK: -
extension FilterList.Workflow {
	enum Action: Equatable {
		case updateFilters
		case showFilters([Filter])
		case updateRaindrops(Filter.ID, count: Int)
		case showRaindrops([Raindrop], filterID: Filter.ID)
		case logFilterError(Filter.LoadingResult.Error)
		case logRaindropError(Raindrop.LoadingResult.Error)
		case openURL(Raindrop)
	}
}

// MARK: -
extension FilterList.Workflow: Workflow {
	public typealias Output = Raindrop

	public struct State {
		var filters: [Filter]
		var isUpdatingFilters: Bool
		var updatingFilters: [Filter.ID: Int]
	}

	public func makeInitialState() -> State {
		.init(
			filters: [],
			isUpdatingFilters: false,
			updatingFilters: [:]
		)
	}

	public func render(
		state: State,
		context: RenderContext<Self>
	) -> FilterList.Screen {
		context.render(
			workflows: state.isUpdatingFilters ? [filterWorker.asAnyWorkflow()] : [],
			keyedWorkflows: .init(
				uniqueKeysWithValues: state.updatingFilters.map { id, count in
					(id.rawValue, raindropWorker(forFilterWith: id, count: count).asAnyWorkflow())
				}
			)
		) { sink in
			.init(
				updateRaindrops: { sink.send(.updateRaindrops($0, count: $1)) },
				isUpdatingRaindrops: state.updatingFilters.keys.contains,
				selectRaindrop: { sink.send(.openURL($0)) },
				filters: state.filters,
				updateFilters: { sink.send(.updateFilters) },
				isUpdatingFilters: state.isUpdatingFilters
			)
		}
	}
}

// MARK: -
private extension FilterList.Workflow {
	var filterWorker: FilterWorker<Service, Action> {
		.init(
			service: service,
			success: Action.showFilters,
			failure: Action.logFilterError
		)
	}

	func raindropWorker(forFilterWith id: Filter.ID, count: Int) -> RaindropWorker<Service, Action> {
		.init(
			service: service,
			source: .filter(id),
			count: count,
			success: { Action.showRaindrops($0, filterID: id) },
			failure: Action.logFilterError
		)
	}
}

// MARK: -
private extension FilterList.Workflow.State {
	mutating func update(with raindrops: [Raindrop], filteredByFilterWith id: Filter.ID) {
		filters = filters.map { filter in
			.init(
				id: filter.id,
				count: filter.count,
				loadedRaindrops: filter.id == id ? raindrops : filter.loadedRaindrops
			)
		}
	}
}

// MARK: -
extension FilterList.Workflow.Action: WorkflowAction {
	typealias WorkflowType = FilterList.Workflow<Service>

	func apply(toState state: inout WorkflowType.State) -> Raindrop? {
		switch self {
		case .updateFilters:
			state.isUpdatingFilters = true
		case let .showFilters(filters):
			state.filters = filters
			state.isUpdatingFilters = false
		case let .updateRaindrops(filterName, filterCount):
			state.updatingFilters[filterName] = filterCount
		case let .showRaindrops(raindrops, filterID):
			state.update(with: raindrops, filteredByFilterWith: filterID)
			state.updatingFilters.removeValue(forKey: filterID)
		case let .logFilterError(error):
			print(error)
		case let .logRaindropError(error):
			print(error)
		case let .openURL(raindrop):
			return raindrop
		}
		return nil
	}
}
