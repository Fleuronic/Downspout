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
import Mixpanel
import Bugsnag

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
		private var mixpanelInstance: MixpanelInstance!
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
	func applicationDidFinishLaunching(_ notification: Notification) {
		Task {
			database = await .init()
			(statusItem, controller) = makeMenuBarItem()

			Mixpanel.initialize(token: .token)
			mixpanelInstance = Mixpanel.mainInstance()
			mixpanelInstance.flushInterval = 0
			track(.appLaunched)

			Bugsnag.start()
		}
	}

	func application(_ application: NSApplication, open urls: [URL]) {
		statusItem.button?.performClick(nil)
	}
}

extension Root.App.Delegate: ASWebAuthenticationPresentationContextProviding {
	// MARK: ASWebAuthenticationPresentationContextProviding
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
	enum Event: String {
		case appLaunched
		case userLoggedIn
		case userLoggedOut
		case sessionStarted
		case sessionEnded
		case urlOpened
	}

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
				self.track(.urlOpened)
			case .login:
				NSWorkspace.shared.open(#URL("downspout://"))
				self.track(.userLoggedIn)
			case .logout:
				self.track(.userLoggedOut)
				Task {
					await self.database.clear()
				}
			case .sessionStart:
				self.track(.sessionStarted)
			case .sessionEnd:
				self.track(.sessionEnded)
			case let .error(error):
				Bugsnag.notifyError(error)
			case .termination:
				NSApplication.shared.terminate(self)
			}
		}
	}

	func track(_ event: Event) {
		mixpanelInstance.track(event: event.rawValue)
		mixpanelInstance.flush()
	}
}

// MARK: -
private extension String {
	static let token = "1870afd0fd345f35249269fad03e8fb8"
}
