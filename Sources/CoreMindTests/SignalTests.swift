//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

@testable import CoreMind
import XCTest

final class SignalTests: XCTestCase {
	var disposables: [Disposable] = [] // keep signal subscriptions around

	func testPipedSinkShouldFireSignal() {
		let e = expectation(description: "signal should fire")
		let (sink, _) = givenSignal("fixture", expectation: e)
		sink(.success("fixture"))

		waitForExpectations(timeout: 0, handler: nil)
	}

	func testPipedSinkShouldFireSignalWithMultipleSubscribers() {
		let e1 = expectation(description: "signal should fire 1")
		let e2 = expectation(description: "signal should fire 2")

		let (sink, signal) = givenSignal("fixture", expectation: e1)
		givenSubscription(signal, value: "fixture", expectation: e2)

		sink(.success("fixture"))

		waitForExpectations(timeout: 0, handler: nil)
	}

	func testPipedSinkShouldReleaseDisposables() {
		let e1 = expectation(description: "disposable should be deallocated 1")
		let (sink, signal) = givenSignal("fixture", expectation: e1)

		// don't save disposable -> subscription not fired
		_ = signal.subscribe {
			_ in
			XCTFail("callback is not expected")
		}

		sink(.success("fixture"))

		waitForExpectations(timeout: 0, handler: nil)
	}

	func testSignalTransformation() {
		let e1 = expectation(description: "final signal should fire 1")
		let e2 = expectation(description: "final signal should fire 2")

		let (sink, signal) = givenSignal("1", expectation: e1)
		// map to new signal
		let signalInt = signal.map { Int($0)! }
		// expect transformed value
		givenSubscription(signalInt, value: 1, expectation: e2)

		sink(.success("1"))

		waitForExpectations(timeout: 0, handler: nil)
	}

	// Helper
	func givenSignal<T: Equatable>(_ v: T, expectation e: XCTestExpectation, file: String = #file, line: UInt = #line) -> ((Swift.Result<T, Error>) -> Void, Signal<T>) {
		let (sink, signal) = Signal<T>.pipe()

		givenSubscription(signal, value: v, expectation: e, file: file, line: line)

		return (sink, signal)
	}

	func givenSubscription<T: Equatable>(_ signal: Signal<T>, value: T, expectation e: XCTestExpectation, file: String = #file, line: UInt = #line) {
		let disp = signal.subscribe {
			switch $0 {
			case let .success(v):
				if v != value {
					self.recordFailure(withDescription: "\(v) != \(value)", inFile: file, atLine: Int(line), expected: false)
				}
			case .failure:
				XCTFail("Signal should not fail")
				self.recordFailure(withDescription: "Signal should not fail", inFile: file, atLine: Int(line), expected: false)
			}

			e.fulfill()
		}

		// keep subscription around
		disposables.append(disp)
	}
}
