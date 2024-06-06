// Copyright © Fleuronic LLC. All rights reserved.

import XCTest

import enum Raindrop.Raindrop

@testable import struct RaindropAPI.API

final class APIGroupSpecTests: XCTestCase {
	func testAPILoadRaindrops() async throws {
		let api = API()
		_ = await api.loadRaindrops()
		XCTAssert(true)
	}

	func testAPILoadRaindropsSuccess() async throws {
		let api = API(
			sleep: { _ in },
			randomBool: { true }
		)
		
		let Raindrops = try await api.loadRaindrops().get()
		XCTAssertEqual(Raindrops, Raindrop.allCases)
	}

	func testAPILoadRaindropsFailureLoadError() async throws {
		let api = API(
			sleep: { _ in },
			randomBool: { false }
		)
		
		let result = await api.loadRaindrops()
		switch result {
		case .failure(.loadError):
			XCTAssert(true)
		default:
			XCTFail()
		}
	}

	func testAPILoadRaindropsFailureSleepError() async throws {
		let underlyingError = NSError(
			domain: "RaindropAPI.API.Error",
			code: 0
		)
		
		let api = API(
			sleep: { _ in throw API.Error.sleepError(underlyingError) },
			randomBool: { true }
		)
		
		switch await api.loadRaindrops() {
		case let .failure(.sleepError(error as NSError)):
			XCTAssertEqual(error, underlyingError)
		default:
			XCTFail()
		}
	}
}
