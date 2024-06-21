//
//  DownspoutApp.swift
//  Downspout
//
//  Created by Jordan Kay on 3/20/24.
//

import AppKit
import Workflow
import WorkflowMenuUI
import WorkflowContainers

import enum CollectionList.CollectionList
import struct Raindrop.Collection
import struct RaindropAPI.API
import struct RaindropDatabase.Database
import class RaindropService.Service

extension CollectionList.App {
	final class Delegate: NSObject {
		private var statusItem: NSStatusItem!
		private var controller: AnyObject!
	}
}

extension CollectionList.App.Delegate: AppDelegate {
	// MARK: AppDelegate
	typealias Workflow = AnyWorkflow<CollectionList.Screen, Void>

	var workflow: Workflow {
		CollectionList.Workflow(
			service: Service(
				api: API(
					accessToken: .init(
						accessToken: "d62deefb-9104-4e98-a5ff-9123789b0e77",
						refreshToken: "",
						expirationDuration: 0,
						tokenType: "Beep"
					)
				),
				database: Database()
			)
		).mapOutput { raindrop in
			NSWorkspace.shared.open(raindrop.url)
		}
	}

	// MARK: NSApplicationDelegate
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Task {
			(statusItem, controller) = await makeMenuBarItem()
		}
	}
}
