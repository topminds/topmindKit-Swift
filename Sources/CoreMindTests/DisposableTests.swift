//
//  DisposableTests.swift
//  topmindKit
//
//  Created by Martin Gratzer on 28/05/2017.
//  Copyright © 2017 topmind mobile app solutions. All rights reserved.
//

import XCTest
@testable import CoreMind

final class DisposableTests: XCTestCase {

    var sut: Disposable? = nil

    func testShouldCallDisposeOnDeinit() {

        let e = expectation(description: "testShouldCallDisposeOnDeinit")
        sut = Disposable { e.fulfill() }
        sut = nil

        waitForExpectations(timeout: 0, handler: nil)
    }
}
