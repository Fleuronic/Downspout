// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Raindrop
import struct Foundation.URL
import protocol Ergo.WorkerOutput

public protocol AddSpec: Sendable where
	RaindropAddResult.Failure: Equatable & Sendable {
	associatedtype RaindropAddResult: WorkerOutput<Raindrop?>

	func addRaindrop(with url: URL) async -> RaindropAddResult
}
