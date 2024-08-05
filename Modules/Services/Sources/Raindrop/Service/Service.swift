// Copyright © Fleuronic LLC. All rights reserved.

@preconcurrency import ReactiveSwift

import struct Dewdrop.AccessToken
import class Semaphore.AsyncSemaphore
import protocol Ergo.WorkerOutput
import protocol Catenary.API
import protocol Catenoid.Database

public final class Service<
	API: Catenary.API,
	Database: TokenSpec,
	ReauthenticationService: AuthenticationSpec
>: @unchecked Sendable where Database.Token == AccessToken {
	let database: Database

	private let authenticatedAPI: @Sendable (AccessToken) -> API
	private let reauthenticationService: ReauthenticationService
	private let validationSemaphore = AsyncSemaphore(value: 1)

	private var validAPI: API
	private var accessToken: AccessToken

	public init(
		api: @Sendable @escaping (AccessToken) -> API,
		database: Database,
		accessToken: AccessToken,
		reauthenticationService: ReauthenticationService
	) {
		validAPI = api(accessToken)
		authenticatedAPI = api

		self.database = database
		self.accessToken = accessToken
		self.reauthenticationService = reauthenticationService
	}
}

// MARK: -
public extension Service {
	typealias APIResult<Resource> = API.Result<Resource>
	typealias DatabaseResult<Resource> = Result<Resource, Never>
	typealias Stream<Result: WorkerOutput> = SignalProducer<Result.Success, Result.Failure>
}

// MARK: -
extension Service {
	var api: API {
		get async {
			await validationSemaphore.wait()

			if accessToken.isValid {
				validationSemaphore.signal()
				return validAPI
			} else {
				let results = await reauthenticationService.reauthenticate(with: accessToken).results
				for await result in results {
					if case let .success(accessToken) = result {
						self.accessToken = accessToken
						validAPI = authenticatedAPI(accessToken)
						storeRefreshedToken(accessToken)
						validationSemaphore.signal()
						return validAPI
					}
				}

				validationSemaphore.signal()
				let invalidAPI = validAPI
				return invalidAPI
			}
		}
	}

	func load<Success, Failure>(
		 apiResult: @Sendable @escaping (API, Database) async -> Result<Success, Failure>,
		 databaseResult: @Sendable @escaping (Database) async -> Result<Success, Never>
	) async -> Stream<Result<Success, Failure>> where Success: Swift.Collection {
		 let api = await api
		 return .init { [database] observer, lifetime in
			 let task = Task {
				 let value = await databaseResult(database).value
				 if !value.isEmpty {
					 observer.send(value: value)
				 }
				 
				 switch await apiResult(api, database) {
				 case let .success(raindrops):
					 observer.send(value: raindrops)
				 case let .failure(error):
					 print(error)
					 observer.send(error: error)
				 }
				 observer.sendCompleted()
			 }

			 lifetime.observeEnded { task.cancel() }
		 }
	 }
}

// MARK: -
extension Service: Equatable {
	public static func ==(lhs: Service, rhs: Service) -> Bool {
		lhs.accessToken == rhs.accessToken
	}
}

// MARK: -
private extension Service {
	func storeRefreshedToken(_ accessToken: AccessToken) {
		Task {
			let results = await database.store(accessToken).results
			for await result in results {
				if case let .failure(error) = result {
					print(error)
				}
			}
		}
	}
}
