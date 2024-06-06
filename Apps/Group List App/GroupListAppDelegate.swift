//
//  RaindropdownApp.swift
//  Raindropdown
//
//  Created by Jordan Kay on 3/20/24.
//

import AppKit
import Workflow
import WorkflowMenuUI

import enum GroupList.GroupList
import struct Raindrop.Group
import struct RaindropAPI.API

extension GroupList.App {
	final class Delegate: NSObject {
		private var statusItem: NSStatusItem!
		private var controller: AnyObject!
	}
}

extension GroupList.App.Delegate: AppDelegate {
	// MARK: AppDelegate
	var title: String {
		"Group List App"
	}

	var workflow: AnyWorkflow<GroupList.Screen, AnyWorkflowAction<GroupList.Workflow<MockRaindropAPI>>> {
		let service = API(apiKey: "bc222074-acff-475c-96e6-868666d488b3")
		return GroupList.Workflow(service: service).mapOutput { raindrop in
			NSWorkspace.shared.open(raindrop.url)
			return .noAction
		}
	}

	// MARK: NSApplicationDelegate
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Task {
			(statusItem, controller) = await makeMenuBarItem()
		}
	}
}

// MARK: -
private extension GroupList.App.Delegate {
	var mockAPI: MockRaindropAPI {
		.init(
			duration: 1,
			result: .success(
				[
					.init(
						name: "Websites",
						collections: [
							"Food and Drink",
							"Politics",
							"Religion"
						].map { name in
							.init(
								name: name,
								collections: [
									.init(
										name: "Restaurants",
										collections: [],
										raindrops: [
											.init(
												name: "Bloomsday Cafe",
												url: .init(string: "https://bloomsdaycafe.com")!
											)
										]
									)
								],
								raindrops: [
									.init(
										name: "Eater Philly",
										url: .init(string: "https://philly.eater.com")!
									)
								]
							)
						}
					),
					.init(
						name: "Collections",
						collections: [
							"Articles",
							"Blog Posts",
							"Comments"
						].map { name in
							.init(
								name: name,
								collections: [
									.init(
										name: "Restaurants",
										collections: [],
										raindrops: [
											.init(
												name: "Bloomsday Cafe",
												url: .init(string: "https://bloomsdaycafe.com")!
											)
										]
									)
								],
								raindrops: [
									.init(
										name: "Eater Philly",
										url: .init(string: "https://philly.eater.com")!
									)
								]
							)
						}
					)
				]
			)
		)
	}
}

/*private extension Group.App.Delegate {
 	@objc func startPressed() {
         Task {
 //			let userID: User.ID = 1967182
 //			let collectionID: Collection.ID = 39563140
             let api = DewdropAPI.API(
 				apiKey: "bc222074-acff-475c-96e6-868666d488b3",
 				importFileFields: ImportFolderCountFields.self
 			)
 //			let filename = "02666548c93e241b.png"
 			let filename = "bookmarks.html"
 			let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
 			let url = homeDirectory.appendingPathComponent("Downloads").appendingPathComponent(filename)

 			switch await api.importFile(at: url, withName: filename) {
 			case let .success(fields): print(fields)
 			case let .failure(error): print(error)
 			}

 //			let result = await api.listBackups()
 //				.map(\.first?.id)
 //				.map { ($0, .html) }
 //				.asyncFlatMap(api.downloadBackup)
 //
 //			switch result {
 //				case let .success(data?): print(data)
 //				case let .failure(error): print(error.message)
 //				default: print("Backups not found.")
 //			}
 //
 //			switch await api.listBackups() {
 //			case let .success(fields): print(fields)
 //			case let .failure(error): print(error)
 //			}
         }
     }
 }*/

