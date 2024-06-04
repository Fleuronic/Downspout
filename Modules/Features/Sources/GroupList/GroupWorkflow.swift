// Copyright © Fleuronic LLC. All rights reserved.

import Workflow
import Ergo
import EnumKit

import struct Raindrop.Group
import struct Raindrop.Raindrop

public extension GroupList {
	struct Workflow {
		public init() {

		}
	}
}

// MARK: -
extension GroupList.Workflow {
	enum Action: CaseAccessible, Equatable {
		case openURL(Raindrop)
	}
}

// MARK: -
extension GroupList.Workflow: Workflow {
	public typealias Output = Raindrop
	public typealias Rendering = GroupList.Screen

	public func makeInitialState() {}

	public func render(
		state: Void,
		context: RenderContext<Self>
	) -> GroupList.Screen {
		context.render { (sink: Sink<Action>) in
			.init(
				name: "Loading…",
				collections: [],
				selectRaindrop: { sink.send(.openURL($0)) }
			)
		}
	}
}

// MARK: -
extension GroupList.Workflow.Action: WorkflowAction {
	typealias WorkflowType = GroupList.Workflow

	func apply(toState state: inout Void) -> Raindrop? {
		associatedValue()
	}
}
