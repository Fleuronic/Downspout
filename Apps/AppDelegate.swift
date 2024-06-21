// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import Workflow
import WorkflowMenuUI
import SFSafeSymbols

@MainActor
protocol AppDelegate: NSApplicationDelegate {
	associatedtype Workflow: AnyWorkflowConvertible where Workflow.Rendering: Screen

	var workflow: Workflow { get async }
}

extension AppDelegate {
	func makeMenuBarItem() async -> (
		NSStatusItem,
		WorkflowHostingController<Workflow.Rendering, Workflow.Output>
	) {
		let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		statusBarItem.button?.image = .init(systemSymbol: .drop)

		let controller = await WorkflowHostingController(workflow: workflow)
		statusBarItem.menu = controller.menu

		return (statusBarItem, controller)
	}
}
