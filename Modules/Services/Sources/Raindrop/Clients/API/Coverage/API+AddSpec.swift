// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct DewdropAPI.API
import struct Foundation.URL
import protocol Catenary.API
import protocol Ergo.WorkerOutput
import protocol RaindropService.AddSpec
import func Foundation.ceil

extension API: AddSpec {
	public func addRaindrop(with url: URL) async -> Self.Result<Raindrop?> {
		switch await api.checkExistence(of: [url]) {
		case let .success(list) where !list.ids.isEmpty:
			return .success(nil)
		case let .failure(error):
			return .failure(error)
		default:
			switch await api.parse(url: url) {
			case let .success(info):
				return await api.createRaindrop(
					url: url,
					title: info.title
				).map(Raindrop.init)
			case let .failure(error):
				print(error)
				return .failure(error)
			}
		}
	}
}
