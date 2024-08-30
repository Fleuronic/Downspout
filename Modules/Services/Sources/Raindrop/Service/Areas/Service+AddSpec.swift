// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Raindrop.Collection
import struct Raindrop.Filter
import struct Foundation.URL
import protocol Ergo.WorkerOutput

extension Service: AddSpec where
	API: AddSpec,
	API.RaindropAddResult == APIResult<Raindrop?>,
	Database: RaindropSpec,
	Database: SaveSpec,
	Database.RaindropSaveResult == DatabaseResult<[Raindrop.ID]> {
	public func addRaindrop(with url: URL) async -> API.RaindropAddResult {
		await api.addRaindrop(with: url).map { raindrop in
			if let raindrop {
				await database.saveAddedRaindrop(raindrop).map { _ in raindrop }.value
			} else {
				nil
			}
		}
	}
}
