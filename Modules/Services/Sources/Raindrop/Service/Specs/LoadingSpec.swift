// Copyright © Fleuronic LLC. All rights reserved.

public protocol LoadingSpec {
	associatedtype GroupLoadingResult

	func loadGroups() async -> GroupLoadingResult
}
