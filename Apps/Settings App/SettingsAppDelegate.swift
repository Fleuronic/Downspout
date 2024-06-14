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

import enum Settings.Settings

extension Settings.App {
	final class Delegate: NSObject {
		private var statusItem: NSStatusItem!
		private var controller: WorkflowHostingController<AnyScreen, Void>!
	}
}

extension Settings.App.Delegate: AppDelegate {
	// MARK: AppDelegate
	var title: String {
		"Settings App"
	}

	var workflow: AnyWorkflow<AnyScreen, Void> {
		workflow(source: .empty)
	}

	// MARK: NSApplicationDelegate
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Task {
			(statusItem, controller) = await makeMenuBarItem()
		}
	}

	func application(_ application: NSApplication, open urls: [URL]) {
		controller.update(workflow: workflow(source: .authorizationCode("<AUTHORIZATION_CODE>")))
		statusItem.button?.performClick(self)
	}
}

private extension Settings.App.Delegate {
	func workflow(source: Settings.Workflow<MockRaindropAuthenticationAPI>.Source) -> AnyWorkflow<AnyScreen, Void> {
		Settings.Workflow(
			source: source,
			service: MockRaindropAuthenticationAPI()
		).mapRendering { section in
			Menu.Screen(sections: [section]).asAnyScreen()
		}.mapOutput { output in
			switch output {
			case let .loginRequest(url):
				NSWorkspace.shared.open(url)
			case .logoutRequest:
				self.controller.update(workflow: self.workflow(source: .empty))
			case .termination:
				NSApplication.shared.terminate(self)
			}
		}
	}
}
