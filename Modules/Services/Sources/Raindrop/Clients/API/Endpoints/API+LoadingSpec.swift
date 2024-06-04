// Copyright © Fleuronic LLC. All rights reserved.

import struct Raindrop.Group
import protocol RaindropService.LoadingSpec

extension API: LoadingSpec {
	public func loadGroups() async -> Group.LoadingResult {
		fatalError()
	}
}

// MARK: -

public extension Group {
	typealias LoadingResult = Swift.Result<[Group], Error>
}
