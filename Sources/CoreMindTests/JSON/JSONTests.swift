//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import XCTest
@testable import CoreMind

final class JSONTests: XCTestCase {

    func testInitWithObject() {
        let sut = try? JSON(json: [ "test": "fixture 1" ])

        if case .object(let value)? = sut {
            XCTAssertEqual("fixture 1", value["test"] as? String)
        } else {
            XCTFail("Incorrect case")
        }
    }

    func testInitWithObjects() {
        let sut = try? JSON(json: [ ["test": "fixture 1"], ["test": "fixture 2"] ])

        if case .objects(let value)? = sut {
            XCTAssertEqual(2, value.count)
        } else {
            XCTFail("Incorrect case")
        }
    }

    func testInitWithArray() {
        let sut = try? JSON(json: [ "A", "B", "C" ])

        if case .array(let value)? = sut {
            XCTAssertEqual([ "A", "B", "C" ], value as? [String])
        } else {
            XCTFail("Incorrect case")
        }
    }

    func testInitInvalidValue() {
        do {
            _ = try JSON(json: NSNull())
            XCTFail("Parsing is expected to fail")
        } catch {

        }
    }

    func testInitWithString() {
        let sut = try? JSON(string: "{\"test\": \"fixture 1\"}")

        if case .object(let value)? = sut {
            XCTAssertEqual("fixture 1", value["test"] as? String)
        } else {
            XCTFail("Incorrect case")
        }
    }

    func testInitWithData() {
        let data = "{\"test\": \"fixture 1\"}".data(using: .utf8)!
        let sut = try? JSON(data: data)

        if case .object(let value)? = sut {
            XCTAssertEqual("fixture 1", value["test"] as? String)
        } else {
            XCTFail("Incorrect case")
        }
    }
}
