// Copyright © Fleuronic LLC. All rights reserved.

public protocol TagSpec {
	associatedtype TagLoadingResult

	func loadTags() async -> TagLoadingResult
}
