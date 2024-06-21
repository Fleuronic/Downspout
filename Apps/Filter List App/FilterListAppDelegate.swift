//
//  DownspoutApp.swift
//  Downspout
//
//  Created by Jordan Kay on 3/20/24.
//

import AppKit
import Workflow
import WorkflowMenuUI

import enum FilterList.FilterList
import struct Raindrop.Filter
import struct RaindropAPI.API

extension FilterList.App {
	final class Delegate: NSObject {
		private var statusItem: NSStatusItem!
		private var controller: AnyObject!
	}
}

extension FilterList.App.Delegate: AppDelegate {
	// MARK: AppDelegate
	var workflow: AnyWorkflow<FilterList.Screen, AnyWorkflowAction<FilterList.Workflow<API>>> {
		FilterList.Workflow(
			service: API(apiKey: "bc222074-acff-475c-96e6-868666d488b3")
		).mapOutput { raindrop in
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
private extension FilterList.App.Delegate {
	var mockAPI: MockRaindropAPI {
		.init(
			duration: 1,
			result: .success([])
		)
	}
}

