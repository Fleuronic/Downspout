// Copyright © Fleuronic LLC. All rights reserved.

import DewdropAPI
import DewdropService

public struct API {
	let api: DewdropAPI.API<ImportFolderFields>

	public init(apiKey: String) {
		api = .init(apiKey: apiKey)
	}
}

// MARK: -
public extension API {
	typealias Result<T> = DewdropAPI.API<ImportFolderFields>.Result<T>
}
