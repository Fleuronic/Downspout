//
//  RaindropdownApp.swift
//  Raindropdown
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

extension CollectionList.App {
	final class Delegate: NSObject {
		private var statusItem: NSStatusItem!
		private var controller: AnyObject!
	}
}

extension CollectionList.App.Delegate: AppDelegate {
	// MARK: AppDelegate
	var title: String {
		"Collection List App"
	}

	var workflow: AnyWorkflow<AnyScreen, Void> {
		CollectionList.Workflow(
			service:  API(apiKey: "d62deefb-9104-4e98-a5ff-9123789b0e77")
		).mapRendering { section in
			Menu.Screen(sections: [section]).asAnyScreen()
		}.mapOutput { raindrop in
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
