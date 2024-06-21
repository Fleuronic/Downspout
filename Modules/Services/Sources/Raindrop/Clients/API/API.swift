// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.AccessToken
import struct DewdropAPI.API
import struct DewdropAPI.Error
import struct DewdropService.ImportFolderFields
import protocol Catena.API

public struct API {
	let api: DewdropAPI.API<ImportFolderFields>
	let accessToken: AccessToken

	public init(accessToken: AccessToken) {
		api = .init(apiKey: accessToken.accessToken)

		self.accessToken = accessToken
	}
}

// MARK: -
extension API: Catena.API {
	public typealias Error = DewdropAPI.Error
}
