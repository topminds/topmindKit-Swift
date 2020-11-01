//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import XCTest

/// http://owensd.io/2015/06/19/xctest-missing-throws-testing.html
func XCTAssertDoesNotThrow(_ fn: @autoclosure () throws -> Void, message: String = ""/*, file: StaticString = #file, line: UInt = #line*/) {
    do {
        try fn()
    } catch {
        XCTFail(message/*, file: file, line: line*/)
    }
}

/// http://owensd.io/2015/06/19/xctest-missing-throws-testing.html
func XCTAssertDoesThrow(_ fn: @autoclosure () throws -> Void, message: String = ""/*, file: StaticString = #file, line: UInt = #line*/) {
    do {
        try fn()
        XCTFail(message/*, file: file, line: line*/)
    } catch {
    }
}
