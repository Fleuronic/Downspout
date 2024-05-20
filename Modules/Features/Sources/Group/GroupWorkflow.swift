// Copyright © Fleuronic LLC. All rights reserved.

import Workflow
import Ergo
import EnumKit

import struct Raindrop.Group
import struct Raindrop.Raindrop

public extension Group {
	struct Workflow {
		private let group: Group

		public init(group: Group) {
			self.group = group
		}
	}
}

// MARK: -
extension Group.Workflow {
	enum Action: CaseAccessible, Equatable {
		case openURL(Raindrop)
	}
}

// MARK: -
extension Group.Workflow: Workflow {
	public typealias Output = Raindrop
	public typealias Rendering = Group.Screen

	public func makeInitialState() {}

	public func render(
		state: Void,
		context: RenderContext<Self>
	) -> Group.Screen {
		context.render { (sink: Sink<Action>) in
			.init(
				name: group.name,
				collections: group.collections,
				selectRaindrop: { sink.send(.openURL($0)) }
			)
		}
	}
}

// MARK: -
extension Group.Workflow.Action: WorkflowAction {
	typealias WorkflowType = Group.Workflow

	func apply(toState state: inout Void) -> Raindrop? {
		associatedValue()
	}
}
