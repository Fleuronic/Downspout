//
//  RaindropdownApp.swift
//  Raindropdown
//
//  Created by Jordan Kay on 3/20/24.
//

import AppKit
import Workflow
import WorkflowMenuUI

import enum Root.Root
import enum Settings.Settings
import RaindropAPI
import WorkflowContainers

extension Root.App {
	final class Delegate: NSObject {
		private var statusItem: NSStatusItem!
		private var controller: AnyObject!
	}
}

extension Root.App.Delegate: AppDelegate {
	// MARK: AppDelegate
	var title: String {
		"Raindropdown"
	}

	var workflow: AnyWorkflow<Menu.Screen<AnyScreen>, Void> {
		workflowBeep()
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

//		controller.update(workflow: workflow(source: .authorizationCode(code)))
		statusItem.button?.performClick(self)
	}
}

private extension Root.App.Delegate {
	func workflowBeep() -> AnyWorkflow<Menu.Screen<AnyScreen>, Void> {
		Root.Workflow(
			service: API(apiKey: "d62deefb-9104-4e98-a5ff-9123789b0e77"),
			authenticationService: Authentication.API()
		).mapOutput { output in
			switch output {
			case let .collectionList(raindrop):
				NSWorkspace.shared.open(raindrop.url)
			case let.settings(output):
				switch output {
				case let .loginRequest(url):
					NSWorkspace.shared.open(url)
				case .logoutRequest:
//					self.controller.update(workflow: self.workflow(source: .empty))
					break
				case .termination:
					NSApplication.shared.terminate(self)
				}
			}
		}
	}
}
