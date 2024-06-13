import AppKit

import enum FilterList.FilterList

let delegate = FilterList.App.Delegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
