// Copyright © Fleuronic LLC. All rights reserved.

import AppKit
import Workflow
import WorkflowMenuUI

protocol AppDelegate: NSApplicationDelegate {
	associatedtype Workflow: AnyWorkflowConvertible where Workflow.Rendering: Screen

	var title: String { get }
	var workflow: Workflow { get async }
}

extension AppDelegate {
	@MainActor
	func makeMenuBarItem() async -> (
		NSStatusItem,
		WorkflowHostingController<Workflow.Rendering, Workflow.Output>
	) {
		let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		statusBarItem.button?.title = title

		let controller = await WorkflowHostingController(workflow: workflow)
		statusBarItem.menu = controller.menu

		return (statusBarItem, controller)
	}
}
