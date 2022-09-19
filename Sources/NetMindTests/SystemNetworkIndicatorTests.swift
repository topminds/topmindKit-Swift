//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

@testable import NetMind
import XCTest

final class SystemNetworkIndicatorTests: XCTestCase {
	var callbackState = false
	var didCallCallback = 0

	override func setUp() {
		didCallCallback = 0
		callbackState = false

		SystemNetworkIndicator.showIndicatorCallback = {
			[weak self] in
			self?.callbackState = $0
			self?.didCallCallback += 1
		}
	}

	override func tearDown() {
		super.tearDown()
		_ = SystemNetworkIndicator.reset()
	}

	func testIndicatorShouldIncement() {
		XCTAssertEqual(SystemNetworkIndicator.startAnimating(), 1)
		XCTAssertTrue(callbackState)
		XCTAssertEqual(1, didCallCallback)
		XCTAssertEqual(SystemNetworkIndicator.startAnimating(), 2)
		XCTAssertTrue(callbackState)
		XCTAssertEqual(2, didCallCallback)
		XCTAssertEqual(SystemNetworkIndicator.startAnimating(), 3)
		XCTAssertTrue(callbackState)
		XCTAssertEqual(3, didCallCallback)
	}

	func testIndicatorShouldDecrement() {
		givenActivities(count: 3)

		didCallCallback = 0
		callbackState = false

		XCTAssertEqual(SystemNetworkIndicator.stopAnimating(), 2)
		XCTAssertTrue(callbackState)
		XCTAssertEqual(1, didCallCallback)

		XCTAssertEqual(SystemNetworkIndicator.stopAnimating(), 1)
		XCTAssertTrue(callbackState)
		XCTAssertEqual(2, didCallCallback)

		XCTAssertEqual(SystemNetworkIndicator.stopAnimating(), 0)
		XCTAssertFalse(callbackState)
		XCTAssertEqual(3, didCallCallback)
	}

	func testIndicatorShouldNotTurnNegative() {
		givenActivities(count: 2)

		didCallCallback = 0
		callbackState = false

		XCTAssertEqual(SystemNetworkIndicator.stopAnimating(), 1)
		XCTAssertTrue(callbackState)
		XCTAssertEqual(1, didCallCallback)

		XCTAssertEqual(SystemNetworkIndicator.stopAnimating(), 0)
		XCTAssertFalse(callbackState)
		XCTAssertEqual(2, didCallCallback)

		XCTAssertEqual(SystemNetworkIndicator.stopAnimating(), 0)
		XCTAssertFalse(callbackState)
		XCTAssertEqual(3, didCallCallback)
	}

	func testShouldReset() {
		givenActivities(count: 3)

		didCallCallback = 0
		callbackState = false

		XCTAssertEqual(SystemNetworkIndicator.reset(), 0)
		XCTAssertFalse(callbackState)
		XCTAssertEqual(1, didCallCallback)
		// sanity check
		XCTAssertEqual(SystemNetworkIndicator.startAnimating(), 1)
	}

	// MARK: Helper

	func givenActivities(count: ActivityCount) {
		let range = (0 ..< count)
		let check = range.enumerated().map { $0.offset + 1 }
		let counts = range.map { _ in SystemNetworkIndicator.startAnimating() }
		XCTAssertEqual(check, counts)
	}
}
