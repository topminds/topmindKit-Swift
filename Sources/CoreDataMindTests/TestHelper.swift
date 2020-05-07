//
//  TestHelper.swift
//  topmindKit
//
//  Created by Martin Gratzer on 05/10/2016.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
//

import XCTest

/// http://owensd.io/2015/06/19/xctest-missing-throws-testing.html
func XCTAssertDoesNotThrow(_ fn: @autoclosure () throws -> (), message: String = ""/*, file: StaticString = #file, line: UInt = #line*/) {
    do {
        try fn()
    } catch {
        XCTFail(message/*, file: file, line: line*/)
    }
}

/// http://owensd.io/2015/06/19/xctest-missing-throws-testing.html
func XCTAssertDoesThrow(_ fn: @autoclosure () throws -> (), message: String = ""/*, file: StaticString = #file, line: UInt = #line*/) {
    do {
        try fn()
        XCTFail(message/*, file: file, line: line*/)
    } catch {
    }
}
