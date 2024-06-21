// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.AccessToken
import protocol Ergo.WorkerOutput
import protocol RaindropService.TokenSpec

extension Database: TokenSpec {
	public func store(_ token: AccessToken) async -> AccessToken.StorageResult {
		do {
			try secureStorage.archive(object: token, key: .accessToken)
			return .success(())
		} catch {
			return .failure(error as! DecodingError)
		}
	}
	
	public func retrieveToken() async -> AccessToken.RetrievalResult {
		do {
			return .success(try secureStorage.unarchive(for: .accessToken))
		} catch {
			return .failure(error as! DecodingError)
		}
	}
	
	public func discardToken() async {
		secureStorage.remove(key: .accessToken)
	}
}

// MARK: -
public extension AccessToken {
	typealias StorageResult = Result<Void, DecodingError>
	typealias RetrievalResult = Result<AccessToken?, DecodingError>
}

// MARK: -
private extension String {
	static let accessToken = String(describing: AccessToken.self)
}
