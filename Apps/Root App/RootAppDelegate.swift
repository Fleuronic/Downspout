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
import URL
import AuthenticationServices

import enum Root.Root
import enum Settings.Settings
import enum RaindropAPI.Authentication
import struct Dewdrop.AccessToken
import struct RaindropAPI.API
import struct RaindropDatabase.Database
import class RaindropService.Service

extension Root.App {
	@MainActor final class Delegate: NSObject {
		private let authenticationAPI = Authentication.API()

		private var database: Database!
		private var statusItem: NSStatusItem!
		private var controller: WorkflowHostingController<Menu.Screen<AnyScreen>, Void>!
	}
}

// MARK: -
extension Root.App.Delegate: AppDelegate {
	// MARK: AppDelegate
	typealias Workflow = AnyWorkflow<Menu.Screen<AnyScreen>, Void>

	var workflow: AnyWorkflow<Menu.Screen<AnyScreen>, Void> {
		workflow(with: .init(loginContextProvider: self))
	}

	// MARK: NSApplicationDelegate
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Task {
			database = await .init()
			(statusItem, controller) = makeMenuBarItem()
		}
	}

	func application(_ application: NSApplication, open urls: [URL]) {
		statusItem.button?.performClick(nil)
	}
}

extension Root.App.Delegate: ASWebAuthenticationPresentationContextProviding {
	#if compiler(<6.0)
	nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
		MainActor.assumeIsolated {
			statusItem.button!.window!
		}
	}
	#else
	func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
		statusItem.button!.window!
	}
	#endif
}

// MARK: -
private extension Root.App.Delegate {
	func workflow(with settingsSource: Settings.Workflow<Authentication.API, Database>.Source) -> Workflow {
		Root.Workflow<Database, Authentication.API, Service<API, Database, Authentication.API>>(
			tokenService: database,
			authenticationService: authenticationAPI,
			settingsSource: settingsSource
		) { [database, authenticationAPI] accessToken in
			.init(
				api: API.init,
				database: database!,
				accessToken: accessToken,
				reauthenticationService: authenticationAPI
			)
		}.mapOutput { output in
			switch output {
			case let .url(url):
				NSWorkspace.shared.open(url)
			case .activation:
				NSWorkspace.shared.open(#URL("downspout://"))
			case .logout:
				Task {
					await self.database.clear()
				}
			case .termination:
				NSApplication.shared.terminate(self)
			}
		}
	}
}
