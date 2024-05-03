//
//  RaindropdownApp.swift
//  Raindropdown
//
//  Created by Jordan Kay on 3/20/24.
//

import Dewdrop
import DewdropAPI
import SwiftUI

@main
struct RaindropdownApp: App {
    var body: some Scene {
        MenuBarExtra("Bookmarks") {
            Button {
                Task {
//					let userID: User.ID = 1967182
                    let api = DewdropAPI.API(apiKey: "bc222074-acff-475c-96e6-868666d488b3")

					let filename = "bookmarks.html"
					let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
					let file = homeDirectory.appendingPathComponent("Downloads").appendingPathComponent(filename)
					let result = await api.parseImport(of: file, withName: filename)

					switch result {
					case let .success(fields):
						print(fields.items[0].bookmarks[0].title)
					case let .failure(error):
						print(error)
					}
                }
            } label: {
                Text("Start")
            }
        }
    }
}
