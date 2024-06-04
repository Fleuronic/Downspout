// Copyright © Fleuronic LLC. All rights reserved.

import XCTest

@testable import struct GroupAPI.API

final class APITests: XCTestCase {
	func testAPI() {
		let api = API()
		XCTAssertNotNil(api)
	}
}
