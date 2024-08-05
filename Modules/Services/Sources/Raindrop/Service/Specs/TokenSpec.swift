// Copyright © Fleuronic LLC. All rights reserved.

import protocol Ergo.WorkerOutput

public protocol TokenSpec: Sendable {
	associatedtype Token: Hashable & Equatable & Sendable
	associatedtype StorageResult: WorkerOutput<Void>
	associatedtype RetrievalResult: WorkerOutput<Token?>

	func store(_ token: Token) async -> StorageResult
	func retrieveToken() async -> RetrievalResult
	func discardToken() async -> StorageResult
}
