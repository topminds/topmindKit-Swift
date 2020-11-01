//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import XCTest
@testable import CoreMind

final class JSONResultParsingTests: XCTestCase {

    func testResultTypeJsonParsing() {
        let result: Swift.Result<JSONObject, Error> = .success([:])
        let parsed: Swift.Result<ParseOk, Error> = result.parse()

        if case .failure(let error) = parsed {
            XCTFail("\(error)")
        }
    }

    func testResultTypeListJsonParsing() {
        let result: Swift.Result<JSONObject, Error> = .success([:])
        let parsed: Swift.Result<ParseOk, Error> = result.parse()

        if case .failure(let error) = parsed {
            XCTFail("\(error)")
        }
    }

    func testResultTypeJsonParsingThrows() {
        let result: Swift.Result<JSONObject, Error> = .success(["hello": ["world": "1"]])
        let parsed: Swift.Result<[ParseNok], Error> = result.parse(key: "hello")

        if case .success(_) = parsed {
            XCTFail("Should not succeed")
        }
    }

    func testResultTypeListJsonParsingThrows() {
        let result: Swift.Result<JSONObject, Error> = .success(["hello": ["world": "1"]])
        let parsed: Swift.Result<[ParseNok], Error> = result.parse(key: "hello")

        if case .success(_) = parsed {
            XCTFail("Should not succeed")
        }
    }
    
}
