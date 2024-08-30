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
extension Root.App.Delegate: AppDelegate, NSWindowDelegate {
	// MARK: AppDelegate
	typealias Workflow = AnyWorkflow<Menu.Screen<AnyScreen>, Void>

	var workflow: AnyWorkflow<Menu.Screen<AnyScreen>, Void> { workflow() }

	// MARK: NSApplicationDelegate
	func applicationDidFinishLaunching(_ notification: Notification) {
		Mixpanel.initialize(token: .token)
		mixpanelInstance = Mixpanel.mainInstance()
		mixpanelInstance.flushInterval = 0
		track(.appLaunched)

		Task {
			database = await .init()
			(statusItem, controller) = makeMenuBarItem()

			window.delegate = self
			window.registerForDraggedTypes([.URL])
		}
	}

	func application(_ application: NSApplication, open urls: [URL]) {
		statusItem.button?.performClick(nil)
	}
}

extension Root.App.Delegate: NSDraggingDestination {
	func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		.copy
	}

	func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		let url = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self])?.first as? URL
		controller.update(workflow: workflow(with: url))
		return true
	}
}

extension Root.App.Delegate: ASWebAuthenticationPresentationContextProviding {
	// MARK: ASWebAuthenticationPresentationContextProviding
	#if compiler(<6.0)
	nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
		MainActor.assumeIsolated { window }
	}
	#else
	func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
		window
	}
	#endif
}

// MARK: -
private extension Root.App.Delegate {
	typealias ServiceType = Service<API, Database, Authentication.API>
	typealias WorkflowType = Root.Workflow<Database, Authentication.API, ServiceType>
	typealias SettingsSource = Settings.Workflow<Database, Authentication.API, ServiceType>.Source

	enum Event: String {
		case appLaunched
		case userLoggedIn
		case userLoggedOut
		case sessionStarted
		case sessionEnded
		case urlOpened
	}

	var window: NSWindow {
		statusItem.button!.window!
	}

	func workflow(with draggedURL: URL? = nil) -> Workflow {
		WorkflowType(
			source: .init(
				collectionListSource: .init(event: draggedURL.map { .addRaindrop(url: $0) } ?? .view),
				settingsSource: .init(loginContextProvider: self)
			),
			tokenService: database,
			authenticationService: authenticationAPI
		) { [database, authenticationAPI] accessToken in
			.init(
				api: API.init,
				database: database!,
				accessToken: accessToken,
				reauthenticationService: authenticationAPI
			)
		}.mapOutput(handle)
	}

	func open(_ url: URL) {
		NSWorkspace.shared.open(url)
	}

	func quit() {
		NSApplication.shared.terminate(self)
	}

	func identify(_ idString: String) {
		mixpanelInstance.identify(distinctId: idString)
		mixpanelInstance.people.set(property: "id", to: idString)
		mixpanelInstance.flush()
	}

	func track(_ event: Event) {
		mixpanelInstance.track(event: event.rawValue)
		mixpanelInstance.flush()
	}

	func notify(_ error: Error) {
		Bugsnag.notifyError(error)
	}

	func handle(_ output: WorkflowType.Output) {
		switch output {
		case let .url(url):
			open(url)
			track(.urlOpened)
		case .login:
			open(.downspout)
			track(.userLoggedIn)
		case let .idString(string):
			identify(string)
		case .logout:
			track(.userLoggedOut)
			Task { await database.clear() }
		case .sessionStart:
			track(.sessionStarted)
		case .sessionEnd:
			track(.sessionEnded)
		case let .error(error):
			notify(error)
		case .termination:
			quit()
		}
	}
}

// MARK: -
private extension String {
	static let token = "1870afd0fd345f35249269fad03e8fb8"
}

private extension URL {
	static let downspout = #URL("downspout://")
}
