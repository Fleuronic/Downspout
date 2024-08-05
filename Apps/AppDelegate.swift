// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import Workflow
import WorkflowMenuUI
import SafeSFSymbols

@MainActor
protocol AppDelegate: NSApplicationDelegate {
	associatedtype Workflow: AnyWorkflowConvertible where Workflow.Rendering: Screen

	var workflow: Workflow { get }
}

extension AppDelegate {
	func makeMenuBarItem() -> (
		NSStatusItem,
		WorkflowHostingController<Workflow.Rendering, Workflow.Output>
	) {
		let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		statusBarItem.button?.image = .init(.drop)

		let controller = WorkflowHostingController(workflow: workflow)
		statusBarItem.menu = controller.menu

		return (statusBarItem, controller)
	}
}
