// Copyright © Fleuronic LLC. All rights reserved.

import struct Foundation.URL
import struct Foundation.URLComponents
import struct Foundation.URLQueryItem
import struct Dewdrop.AccessToken
import protocol Ergo.WorkerOutput

public protocol AuthenticationSpec: Equatable, Sendable {
	associatedtype AuthenticationResult: WorkerOutput<AccessToken> & Sendable

	static var clientID: String { get }
	static var authorizationEndpoint: URL { get }
	static var accountDeletionEndpoint: URL { get }

	func authenticate(withAuthorizationCode: String) async -> AuthenticationResult
	func reauthenticate(with accessToken: AccessToken) async -> AuthenticationResult

	static func redirectURI(for target: RedirectTarget) -> URL
}

// MARK: -
public extension AuthenticationSpec {
	static var authorizationURL: URL {
		var components = URLComponents(url: authorizationEndpoint, resolvingAgainstBaseURL: false)!
		let queryItems: [URLQueryItem] = [
			.init(
				name: "redirect_uri",
				value: redirectURI(for: .app).absoluteString
			),
			.init(
				name: "client_id",
				value: clientID
			)
		]
		
		components.queryItems = queryItems
		return components.url!
	}

	static var accountDeletionURL: URL {
		let components = URLComponents(url: accountDeletionEndpoint, resolvingAgainstBaseURL: false)!
		return components.url!
	}
}

// MARK: -
public enum RedirectTarget {
	case web
	case app
}
