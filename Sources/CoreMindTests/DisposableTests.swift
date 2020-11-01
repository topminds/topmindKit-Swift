//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

@testable import CoreMind
import XCTest

final class DisposableTests: XCTestCase {
	var sut: Disposable?

	func testShouldCallDisposeOnDeinit() {
		let e = expectation(description: "testShouldCallDisposeOnDeinit")
		sut = Disposable { e.fulfill() }
		sut = nil

		waitForExpectations(timeout: 0, handler: nil)
	}
}
