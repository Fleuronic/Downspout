import AppKit

import enum TagList.TagList

let delegate = TagList.App.Delegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
