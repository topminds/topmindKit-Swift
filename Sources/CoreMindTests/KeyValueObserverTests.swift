//
//  KeyValueObserverTests.swift
//  topmindKit
//
//  Created by Martin Gratzer on 28/05/2017.
//  Copyright © 2017 topmind mobile app solutions. All rights reserved.
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
    var sut: KeyValueObserver<String>? = nil

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
