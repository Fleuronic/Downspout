// Copyright © Fleuronic LLC. All rights reserved.

import Foundation
import Raindrop
import RaindropService
import DewdropAPI
import DewdropService

extension API: LoadingSpec {
	public func loadGroups() async -> Group.LoadingResult {
		let api = DewdropAPI.API(
		   apiKey: "bc222074-acff-475c-96e6-868666d488b3",
		   importFileFields: ImportFolderCountFields.self
		)

		return await api.listBackups().map { _ in
			[]
		}
	}
}

// MARK: -

public extension Group {
	typealias LoadingResult = DewdropAPI.API<ImportFolderCountFields>.Result<[Group]>
}

//let filename = "bookmarks.html"
//let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
//let url = homeDirectory.appendingPathComponent("Downloads").appendingPathComponent(filename)
