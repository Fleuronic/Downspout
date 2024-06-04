import AppKit

import enum GroupList.GroupList

let delegate = GroupList.App.Delegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
