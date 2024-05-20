import AppKit
import struct Raindrop.Group

let delegate = Group.App.Delegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
