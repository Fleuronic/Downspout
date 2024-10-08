// Copyright © Fleuronic LLC. All rights reserved.

import enum Dewdrop.ItemType
import struct Dewdrop.Filter
import struct DewdropAPI.API
import struct DewdropService.IdentifiedFilter
import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Raindrop.Tag
import struct Foundation.URL
import struct Foundation.KeyPathComparator
import protocol Catenary.API
import protocol Ergo.WorkerOutput
import protocol RaindropService.RaindropSpec
import func Foundation.ceil

extension API: RaindropSpec {
	public func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) async -> Self.Result<[Raindrop]> {
		await paging(to: count) { page in
			await api.listRaindrops(inCollectionWith: id, onPage: page, listing: .maxPerPage)
		}
	}

	public func loadRaindrops(taggedWithTagNamed name: String, count: Int) async -> Self.Result<[Raindrop]> {
		await paging(to: count) { page in
			await api.listRaindrops(searchingFor: "#\"\(name)\"", onPage: page, listing: .maxPerPage)
		}
	}

	public func loadRaindrops(filteredByFilterWith id: Dewdrop.Filter.ID, count: Int) async -> Self.Result<[Raindrop]> {
		await paging(to: count) { page in
			await api.listRaindrops(searchingFor: Filter.query(for: id), onPage: page, listing: .maxPerPage)
		}
	}
}

// MARK: -
private extension API {
	func paging(to count: Int, fields: @Sendable @escaping (Int) async -> Self.Result<[RaindropListFields]>) async -> Self.Result<[Raindrop]> {
		await withTaskGroup(of: (Int, Self.Result<[RaindropListFields]>).self) { taskGroup in
			let pageCount = Int(ceil(Double(count) / Double(Int.maxPerPage)))
			for page in 0..<pageCount {
				taskGroup.addTask { await (page, fields(page)) }
			}

			var list: [RaindropListFields] = []
			var results: [Int: Self.Result<[RaindropListFields]>] = [:]
			for await task in taskGroup { results[task.0] = task.1 }

			let sortedResults = results.sorted { $0.0 < $1.0 }.map(\.value)
			for result in sortedResults {
				switch result {
				case let .success(fields):
					list.append(contentsOf: fields)
				case let .failure(error):
					return .failure(error)
				}
			}

			return .success(list.sorted(using: KeyPathComparator(\.id.rawValue, order: .reverse)).map(Raindrop.init))
		}
	}
}

// MARK: -
private extension Int {
	static let maxPerPage = 50
}
