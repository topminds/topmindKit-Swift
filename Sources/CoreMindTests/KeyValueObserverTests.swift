//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import XCTest
@testable import CoreMind

final class FixtureObject: NSObject {
    @objc var testProperty: String = "initial_fixture" {
        willSet { willChangeValue(forKey: "testProperty") }
        didSet { didChangeValue(forKey: "testProperty") }
    }
}

final class KeyValueObserverTests: XCTestCase {
    var sut: KeyValueObserver<String>?

    func testShouldReportChanges() {
        let object = FixtureObject()

        let e = expectation(description: "testShouldReportChanges")
        sut = KeyValueObserver<String>(object: object, keyPath: #keyPath(FixtureObject.testProperty)) {
            change in

            XCTAssertEqual("initial_fixture", change.old)
            XCTAssertEqual("new_fixture", change.new)

            e.fulfill()
        }

        object.testProperty = "new_fixture"

        waitForExpectations(timeout: 0, handler: nil)

    }

    func testShouldUnregisterOnDispose() {
        let object = FixtureObject()

        sut = KeyValueObserver<String>(object: object, keyPath: #keyPath(FixtureObject.testProperty)) {
            _ in
            XCTFail()
        }

        sut = nil

        object.testProperty = "new_fixture"
    }
}
