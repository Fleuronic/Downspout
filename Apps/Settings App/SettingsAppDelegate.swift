//
//  RaindropdownApp.swift
//  Raindropdown
//
//  Created by Jordan Kay on 3/20/24.
//

import AppKit
import Workflow
import WorkflowMenuUI

import enum Settings.Settings
import struct Raindrop.Collection
import struct RaindropAPI.API

extension Settings.App {
	final class Delegate: NSObject {
		private var statusItem: NSStatusItem!
		private var controller: AnyObject!
	}
}

extension Settings.App.Delegate: AppDelegate {
	// MARK: AppDelegate
	var title: String {
		"Settings App"
	}

	var workflow: AnyWorkflow<Settings.Screen, Void> {
		Settings.Workflow().mapOutput {
			NSApplication.shared.terminate(self)
		}
	}

	// MARK: NSApplicationDelegate
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Task {
			(statusItem, controller) = await makeMenuBarItem()
		}
	}
}
