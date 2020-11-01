//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//
import Foundation

open class ConcurrentOperation: Operation {
	public internal(set) var error: Swift.Error?

	internal private(set) var state = State.ready {
		willSet {
			willChangeValue(forKey: newValue.keyPath)
			willChangeValue(forKey: state.keyPath)
		}
		didSet {
			didChangeValue(forKey: oldValue.keyPath)
			didChangeValue(forKey: state.keyPath)
		}
	}

	override open func start() {
		if isCancelled {
			error = ConcurrentOperation.Error.cancelled
			state = .finished
		} else {
			state = .executing
			main()
		}
	}

	override open func cancel() {
		super.cancel()

		error = ConcurrentOperation.Error.cancelled
		if isExecuting {
			state = .finished
		}
	}

	override open var isReady: Bool {
		super.isReady && state == .ready
	}

	override open var isExecuting: Bool {
		state == .executing
	}

	override open var isFinished: Bool {
		state == .finished
	}

	override open var isAsynchronous: Bool {
		true
	}

	open func finish(error: Swift.Error?) {
		self.error = error
		state = .finished
	}
}

extension ConcurrentOperation {
	public enum Error: Swift.Error {
		case cancelled
		case notExecuted
	}

	internal enum State {
		case ready, executing, finished

		// ATTENTION: do NOT use Swift's #keyPath.
		//            it returns incorrect keypath for Objc is* getters
		var keyPath: String {
			switch self {
			case .ready: return "isReady"
			case .executing: return "isExecuting"
			case .finished: return "isFinished"
			}
		}
	}
}
