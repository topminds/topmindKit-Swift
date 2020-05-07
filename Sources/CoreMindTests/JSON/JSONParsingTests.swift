//
//  JSONParsingTests.swift
//  topmindKit
//
//  Created by Martin Gratzer on 29/03/2017.
//  Copyright © 2017 topmind mobile app solutions. All rights reserved.
//

import XCTest
@testable import CoreMind

final class JSONParsingTests: XCTestCase {

    func testSingleObjectParsing() {
        let sut = try! JSON(json: [:])
        let parsed: Swift.Result<ParseOk, Error> = sut.parse()

        if case .failure(let error) = parsed {
            XCTFail("\(error)")
        }
    }

    func testSingleObjectParsingFails() {
        let sut = try! JSON(json: [:])
        let parsed: Swift.Result<ParseNok, Error> = sut.parse()

        if case .success(_) = parsed {
            XCTFail("Should not succeed")
        }
    }

    func testMultipleObjectsParsing() {
        let sut = try! JSON(json: [[:], [:], [:]])
        let parsed: Swift.Result<[ParseOk], Error> = sut.parse()

        if case .failure(let error) = parsed {
            XCTFail("\(error)")
        }
    }

    func testMultipleObjectsParsingFails() {
        let sut = try! JSON(json: [[:], [:], [:]])
        let parsed: Swift.Result<[ParseNok], Error> = sut.parse()

        if case .success(_) = parsed {
            XCTFail("Should not succeed")
        }
    }


    func testDecodableObjectParsing() {
        let jsonDataOk = try! JSONEncoder().encode(Fixture(name: "Fixture"))
        let sut = try! JSON(data: jsonDataOk)
        let parsed: Swift.Result<Fixture, Error> = sut.parse()

        if case .failure(let error) = parsed {
            XCTFail("\(error)")
        }
    }

    func testMultipleDecodableObjectParsing() {
        let jsonDataOkList = try! JSONEncoder().encode([Fixture(name: "Fixture1"), Fixture(name: "Fixture2")])
        let sut = try! JSON(data: jsonDataOkList)
        let parsed: Swift.Result<[Fixture], Error> = sut.parseList()

        if case .failure(let error) = parsed {
            XCTFail("\(error)")
        }
    }
    
}
