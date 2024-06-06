// Copyright © Fleuronic LLC. All rights reserved.

import Foundation
import Raindrop
import RaindropService
import DewdropAPI
import DewdropService

extension API: GroupSpec {
	public func loadGroups() async -> Group.LoadingResult {
		let api = DewdropAPI.API(apiKey: apiKey)
		return await api.fetchUserAuthenticatedDetails().map { fields in
			fields.groups.map { group in
				.init(name: group.title, collections: [])
			}
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
