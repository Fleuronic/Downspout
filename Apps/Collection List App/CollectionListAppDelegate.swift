//
//  RaindropdownApp.swift
//  Raindropdown
//
//  Created by Jordan Kay on 3/20/24.
//

import AppKit
import Workflow
import WorkflowMenuUI

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

	var workflow: AnyWorkflow<CollectionList.Screen, AnyWorkflowAction<CollectionList.Workflow<API>>> {
		let service = API(apiKey: "bc222074-acff-475c-96e6-868666d488b3")
		return CollectionList.Workflow(service: service).mapOutput { raindrop in
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
