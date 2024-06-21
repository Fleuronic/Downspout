//
//  DownspoutApp.swift
//  Downspout
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
	typealias Workflow = AnyWorkflow<TagList.Screen, Void>

	var workflow: Workflow {
		TagList.Workflow(
			service: MockRaindropService()
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
