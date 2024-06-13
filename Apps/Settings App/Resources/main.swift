import AppKit

import enum Settings.Settings

let delegate = Settings.App.Delegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
