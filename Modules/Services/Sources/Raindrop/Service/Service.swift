// Copyright © Fleuronic LLC. All rights reserved.

import InitMacro

import struct Dewdrop.AccessToken
import struct ReactiveSwift.SignalProducer
import class Semaphore.AsyncSemaphore
import protocol Ergo.WorkerOutput
import protocol Catena.API
import protocol Catena.Database

public final class Service<
	API: Catena.API,
	Database: Catena.Database & TokenSpec,
	ReauthenticationService: AuthenticationSpec
>: @unchecked Sendable where
	Database.Token == AccessToken {
	let database: Database
	let reauthenticationService: ReauthenticationService

	private let authenticatedAPI: @Sendable (AccessToken) -> API
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

extension Service {
	@MainActor var api: API {
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
}

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

extension Service: Equatable {
	public static func ==(lhs: Service, rhs: Service) -> Bool {
		lhs.accessToken == rhs.accessToken
	}
}

public extension Service {
	typealias APIResult<Resource> = API.Result<Resource>
	typealias Stream<Result: WorkerOutput> = SignalProducer<Result.Success, Result.Failure>
}
