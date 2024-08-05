// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.AccessToken
import protocol Ergo.WorkerOutput
import protocol RaindropService.TokenSpec

extension Database: TokenSpec {
	public func store(_ token: AccessToken) async -> AccessToken.StorageResult {
		do {
			try keychain.store(token, query: .credential(for: .accessToken))
			return .success(())
		} catch {
			return .failure(error)
		}
	}
	
	public func retrieveToken() async -> AccessToken.RetrievalResult {
		do {
			return .success(try keychain.retrieve(.credential(for: .accessToken)))
		} catch {
			return .failure(error)
		}
	}
	
	public func discardToken() async -> AccessToken.StorageResult {
		do {
			try keychain.remove(.credential(for: .accessToken))
			return .success(())
		} catch {
			return .failure(error)
		}
	}
}

// MARK: -
public extension AccessToken {
	typealias StorageResult = Result<Void, Error>
	typealias RetrievalResult = Result<AccessToken?, Error>
}

// MARK: -
private extension String {
	static let accessToken = String(describing: AccessToken.self)
}
