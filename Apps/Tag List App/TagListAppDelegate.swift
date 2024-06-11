//
//  RaindropdownApp.swift
//  Raindropdown
//
//  Created by Jordan Kay on 3/20/24.
//

import AppKit
import Workflow
import WorkflowMenuUI

import enum TagList.TagList
import struct Raindrop.Tag
import struct RaindropAPI.API

extension TagList.App {
	final class Delegate: NSObject {
		private var statusItem: NSStatusItem!
		private var controller: AnyObject!
	}
}

extension TagList.App.Delegate: AppDelegate {
	// MARK: AppDelegate
	var title: String {
		"Tag List App"
	}

	var workflow: AnyWorkflow<TagList.Screen, AnyWorkflowAction<TagList.Workflow<API>>> {
		let service = API(apiKey: "bc222074-acff-475c-96e6-868666d488b3")
		return TagList.Workflow(service: service).mapOutput { raindrop in
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
private extension TagList.App.Delegate {
	var mockAPI: MockRaindropAPI {
		.init(
			duration: 1,
			result: .success([])
		)
	}
}

