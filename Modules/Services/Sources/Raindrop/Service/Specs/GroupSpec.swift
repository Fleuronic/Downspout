// Copyright © Fleuronic LLC. All rights reserved.

public protocol GroupSpec {
	associatedtype GroupLoadingResult

	func loadGroups() async -> GroupLoadingResult
}
