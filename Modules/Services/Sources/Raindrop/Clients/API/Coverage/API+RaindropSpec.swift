// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Tag
import struct DewdropAPI.API
import struct DewdropService.ImportFolderFields
import struct DewdropService.RaindropDetailsFields
import protocol Ergo.WorkerOutput
import protocol RaindropService.RaindropSpec
import func Foundation.ceil

extension API: RaindropSpec {
	public func loadRaindrops(inCollectionWith id: Collection.ID, count: Int) async -> Raindrop.LoadingResult {
		await paging(to: count) { page in
			await api.listRaindrops(inCollectionWith: id, onPage: page, listing: .maxPerPage)
		}
	}

	public func loadRaindrops(taggedByTagNamed name: String, count: Int) async -> Raindrop.LoadingResult {
		await paging(to: count) { page in
			await api.listRaindrops(searchingFor: "#\"\(name)\"", onPage: page, listing: .maxPerPage)
		}
	}
}

// MARK: -
private extension API {
	func paging(to count: Int, fields: @escaping (Int) async -> Result<[RaindropDetailsFields]>) async -> Raindrop.LoadingResult {
		await withTaskGroup(of: (Int, Result<[RaindropDetailsFields]>).self) { taskGroup in
			let pageCount = Int(ceil(Double(count) / Double(Int.maxPerPage)))
			for page in 0..<pageCount {
				taskGroup.addTask { await (page, fields(page)) }
			}

			var list: [RaindropDetailsFields] = []
			var results: [Int: Result<[RaindropDetailsFields]>] = [:]
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

			return .success(
				list.map { raindrop in
					.init(
						id: raindrop.id,
						collectionID: raindrop.collection.id,
						title: raindrop.title,
						url: raindrop.url
					)
				}
			)
		}
	}
}

// MARK: -
public extension Raindrop {
	typealias LoadingResult = API.Result<[Raindrop]>
}

private extension Int {
	static let maxPerPage = 50
}
