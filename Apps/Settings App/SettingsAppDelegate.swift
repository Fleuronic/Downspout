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
import enum RaindropAPI.Authentication

extension Settings.App {
	final class Delegate: NSObject {
		private var statusItem: NSStatusItem!
		private var controller: WorkflowHostingController<Settings.Screen, Void>!
	}
}

extension Settings.App.Delegate: AppDelegate {
	// MARK: AppDelegate
	var title: String {
		"Settings App"
	}

	var workflow: AnyWorkflow<Settings.Screen, Void> {
		workflow(source: .basic)
	}

	// MARK: NSApplicationDelegate
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Task {
			(statusItem, controller) = await makeMenuBarItem()
		}
	}

	func application(_ application: NSApplication, open urls: [URL]) {
		guard
			let url = urls.first,
			let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
			let code = components.queryItems?.first?.value else { return }

		controller.update(workflow: workflow(source: .authorizationCode(code)))
		statusItem.button?.performClick(self)
	}
}

private extension Settings.App.Delegate {
	func workflow(source: Settings.Workflow<Authentication.API>.Source) -> AnyWorkflow<Settings.Screen, Void> {
		Settings.Workflow(
			source: source,
			service: Authentication.API()
		).mapOutput { output in
			switch output {
			case let .loginRequest(url):
				NSWorkspace.shared.open(url)
			case .logoutRequest:
				self.controller.update(workflow: self.workflow(source: .basic))
			case .termination:
				NSApplication.shared.terminate(self)
			}
		}
	}
}
