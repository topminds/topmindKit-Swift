//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

@testable import CoreMind
import XCTest

final class JSONParsingTests: XCTestCase {
	func testSingleObjectParsing() throws {
		let sut = try JSON(json: [:])
		let parsed: Swift.Result<ParseOk, Error> = sut.parse()

		if case let .failure(error) = parsed {
			XCTFail("\(error)")
		}
	}

	func testSingleObjectParsingFails() throws {
		let sut = try JSON(json: [:])
		let parsed: Swift.Result<ParseNok, Error> = sut.parse()

		if case .success = parsed {
			XCTFail("Should not succeed")
		}
	}

	func testMultipleObjectsParsing() throws {
		let sut = try JSON(json: [[:], [:], [:]])
		let parsed: Swift.Result<[ParseOk], Error> = sut.parse()

		if case let .failure(error) = parsed {
			XCTFail("\(error)")
		}
	}

	func testMultipleObjectsParsingFails() throws {
		let sut = try JSON(json: [[:], [:], [:]])
		let parsed: Swift.Result<[ParseNok], Error> = sut.parse()

		if case .success = parsed {
			XCTFail("Should not succeed")
		}
	}

	func testDecodableObjectParsing() throws {
		let jsonDataOk = try JSONEncoder().encode(Fixture(name: "Fixture"))
		let sut = try JSON(data: jsonDataOk)
		let parsed: Swift.Result<Fixture, Error> = sut.parse()

		if case let .failure(error) = parsed {
			XCTFail("\(error)")
		}
	}

	func testMultipleDecodableObjectParsing() throws {
		let jsonDataOkList = try JSONEncoder().encode([Fixture(name: "Fixture1"), Fixture(name: "Fixture2")])
		let sut = try JSON(data: jsonDataOkList)
		let parsed: Swift.Result<[Fixture], Error> = sut.parseList()

		if case let .failure(error) = parsed {
			XCTFail("\(error)")
		}
	}
}
