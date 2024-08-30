import AppKit
import Bugsnag

import enum Root.Root

@objc(Application) final class Application: NSApplication {
	// MARK: NSApplication
	override func reportException(_ exception: NSException) {
		Bugsnag.notify(exception)
		super.reportException(exception)
	}
}

Bugsnag.start()

let delegate = Root.App.Delegate()
Application.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
