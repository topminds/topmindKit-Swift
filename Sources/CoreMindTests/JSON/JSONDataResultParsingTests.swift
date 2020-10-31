//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import XCTest
@testable import CoreMind

struct Fixture: Codable {
    let name: String
}

struct Fixture2: Codable {
    let name2: String
}

final class JSONDataResultParsingTests: XCTestCase {

    let jsonDataOk = try! JSONEncoder().encode(Fixture(name: "Fixture"))
    let jsonDataOkList = try! JSONEncoder().encode([Fixture(name: "Fixture1"), Fixture(name: "Fixture2")])
    let jsonDataNok = try! JSONEncoder().encode(Fixture2(name2: "Fixture2"))
    let jsonDataNokList = try! JSONEncoder().encode([Fixture2(name2: "Fixture1"), Fixture2(name2: "Fixture2")])

    func testResultTypeJsonParsing() {
        let result: Swift.Result<Data, Error> = .success(jsonDataOk)
        let parsed: Swift.Result<Fixture, Error> = result.parse()

        if case .failure(let error) = parsed {
            XCTFail("\(error)")
        }
    }

    func testResultTypeListJsonParsing() {
        let result: Swift.Result<Data, Error> = .success(jsonDataOkList)
        let parsed: Swift.Result<[Fixture], Error> = result.parse()

        if case .failure(let error) = parsed {
            XCTFail("\(error)")
        }
    }

    func testResultTypeJsonParsingThrows() {
        let result: Swift.Result<Data, Error> = .success(jsonDataNok)
        let parsed: Swift.Result<Fixture, Error> = result.parse()

        if case .success(_) = parsed {
            XCTFail("Should not succeed")
        }
    }

    func testResultTypeListJsonParsingThrows() {
        let result: Swift.Result<Data, Error> = .success(jsonDataNokList)
        let parsed: Swift.Result<[Fixture], Error> = result.parse()

        if case .success(_) = parsed {
            XCTFail("Should not succeed")
        }
    }
    
}
