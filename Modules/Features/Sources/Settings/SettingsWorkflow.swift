// Copyright © Fleuronic LLC. All rights reserved.

import Ergo
import class Workflow.RenderContext
import protocol Workflow.Workflow
import protocol Workflow.WorkflowAction

public extension Settings {
	struct Workflow {
		public init() {}
	}
}

// MARK: -
extension Settings.Workflow {
	enum Action: Equatable {
		case quit
	}
}

// MARK: -
extension Settings.Workflow: Workflow {
	public typealias Output = Void

	public func makeInitialState() -> Void {}

	public func render(
		state: Void,
		context: RenderContext<Self>
	) -> Settings.Screen {
		context.render { sink in
			.init(
				quit: { sink.send(Action.quit) }
			)
		}
	}
}

// MARK: -
extension Settings.Workflow.Action: WorkflowAction {
	typealias WorkflowType = Settings.Workflow

	func apply(toState state: inout WorkflowType.State) -> Void? { () }
}
