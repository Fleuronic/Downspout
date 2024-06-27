//
//  File.swift
//  
//
//  Created by Jordan Kay on 6/21/24.
//

import struct ReactiveSwift.SignalProducer
import class ReactiveSwift.Signal

extension SignalProducer where Error == Never {
	init(handler: @escaping ((Value) -> Void) async -> Void) {
		self = .init { observer, lifetime in
			let task = Task {
				await handler(observer.send)
				observer.sendCompleted()
			}
			
			lifetime.observeEnded { task.cancel() }
		}
	}
}
