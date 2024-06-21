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
import RaindropAPI
import RaindropDatabase

import enum Settings.Settings

extension Settings.App {
	@MainActor
	final class Delegate: NSObject {
		private var statusItem: NSStatusItem!
		private var controller: WorkflowHostingController<Settings.Screen, Void>!
	}
}

extension Settings.App.Delegate: AppDelegate {
	// MARK: AppDelegate
	typealias Workflow = AnyWorkflow<Settings.Screen, Void>

	var workflow: Workflow {
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
	func workflow(source: Settings.Workflow<MockRaindropAuthenticationAPI, MockRaindropDatabase>.Source) -> Workflow {
		Settings.Workflow(
			source: source,
			authenticationService: .init(),
			tokenService: .init(accessToken: .mock)
		).mapOutput { output in
			switch output {
			case let .loginURL(url):
				NSWorkspace.shared.open(url)
			case .termination:
				NSApplication.shared.terminate(self)
			default:
				break
			}
		}
	}
}
