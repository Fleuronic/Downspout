import AppKit

import enum CollectionList.CollectionList

let delegate = CollectionList.App.Delegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
