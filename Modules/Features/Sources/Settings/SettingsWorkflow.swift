// Copyright © Fleuronic LLC. All rights reserved.

import Ergo

import struct Foundation.URL
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
		case logIn
		case logOut
		case quit
	}
}

// MARK: -
extension Settings.Workflow: Workflow {
	public enum Output {
		case login(URL)
		case termination
	}

	public func makeInitialState() -> Void {}

	public func render(
		state: Void,
		context: RenderContext<Self>
	) -> Settings.Screen {
		context.render { sink in
			.init(
				logIn: { sink.send(Action.logIn) },
				logOut: { sink.send(Action.logOut) },
				quit: { sink.send(Action.quit) }
			)
		}
	}
}

// MARK: -
extension Settings.Workflow.Action: WorkflowAction {
	typealias WorkflowType = Settings.Workflow

	func apply(toState state: inout WorkflowType.State) -> WorkflowType.Output? { 
		switch self {
		case .logIn: .login(.authenticationURL)
		case .logOut: nil
		case .quit: .termination
		}
	}
}

private extension URL {
	static let authenticationURL = Self(
		string: "https://raindrop.io/oauth/authorize?redirect_uri=https://fleuronic.com/raindropdown&client_id=65fb6ac6592feb0ab882b20b"
	)!
}
