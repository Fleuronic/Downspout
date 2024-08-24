// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.AccessToken
import struct DewdropAPI.API
import struct DewdropAPI.Error
import struct DewdropService.ImportFolderFields
import protocol Catenary.API

public struct API {
	let api: DewdropAPI.API<
		RaindropListFields,
		CollectionListFields,
		UserGroupFields,
		ImportFolderFields
	>

	@Sendable public init(accessToken: AccessToken) {
		api = .init(apiKey: accessToken.accessToken)
	}
}

// MARK: -
extension API: Catenary.API {
	public typealias Error = DewdropAPI.Error
}
