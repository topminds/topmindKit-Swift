//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import XCTest
@testable import CoreMind

final class ResultTests: XCTestCase {

    func testInitWithSuccess() {
        let sut = Swift.Result { try nonThrowing() }

        switch sut {
        case .success(let value): XCTAssertTrue(value)
        case .failure(_): XCTFail()
        }
    }

    func testInitWithThrowing() {
        let sut = Swift.Result { try throwing() }

        switch sut {
        case .success(_): XCTFail()
        case .failure(let error): XCTAssertEqual(error as? String, "fixture throw")
        }
    }    

    func testValueSuccess() {
        let sut = Swift.Result<String, String>.success("fixture")
        XCTAssertEqual("fixture", sut.value)
    }

    func testValueFailure() {
        let sut: Swift.Result<String, Error> = .failure("fixture")
        XCTAssertNil(sut.value)
    }

    func testErrorSuccess() {
        let sut: Swift.Result<String, Error> = .success("fixture")
        XCTAssertNil(sut.error)
    }

    func testErrorFailure() {
        let sut: Swift.Result<String, Error> = .failure("fixture")
        XCTAssertNotNil(sut.error)
        XCTAssertEqual("fixture", sut.error as? String)
    }

    func testResolvingSuccess() {
        let sut: Swift.Result<String, Error> = .success("fixture ok")
        XCTAssertEqual(try? sut.resolve(), "fixture ok")
    }

    func testResolvingFailure() {
        let sut: Swift.Result<String, Error> = Swift.Result.failure("fixture nok")
        do {
            _ = try sut.resolve()
            XCTFail()
        } catch {
            XCTAssertEqual(error as? String, "fixture nok")
        }
    }

    func testMapingOverSuccess() {
        let sut: Swift.Result<String, Error> = .success("fixture ok")
        let mapped: Swift.Result<Bool, Error> = sut.map {
            XCTAssertEqual($0, "fixture ok")
            return true
        }

        switch mapped {
        case .success(let value): XCTAssertTrue(value)
        case .failure(_): XCTFail()
        }
    }

    func testMappingOverFailure() {
        let sut: Swift.Result<String, Error> = .failure("fixture nok")
        let mapped: Swift.Result<Bool, Error> = sut.map {
            XCTAssertEqual($0, "fixture nok")
            return false
        }

        switch mapped {
        case .success(_): XCTFail()
        case .failure(let error): XCTAssertEqual(error as? String, "fixture nok")
        }
    }

    func testFlatMappingOverSuccess() {
        let sut: Swift.Result<String, Error> = .success("fixture ok")
        let mapped: Swift.Result<Bool, Error> = sut.flatMap {
            XCTAssertEqual($0, "fixture ok")
            return .success(true)
        }

        switch mapped {
        case .success(let value): XCTAssertTrue(value)
        case .failure(_): XCTFail()
        }
    }

    func testFlatMappingOverFailure() {
        let sut: Swift.Result<String, Error> = .failure("fixture nok")
        let mapped: Swift.Result<Bool, Error> = sut.flatMap {
            XCTAssertEqual($0, "fixture nok")
            return .failure("fixture nok")
        }

        switch mapped {
        case .success(_): XCTFail()
        case .failure(let error): XCTAssertEqual(error as? String, "fixture nok")
        }
    }
    
    func testDoubleNullWithBothNils() {
        let sut: Swift.Result<Any?, Error>? = Swift.Result(nil, nil)
        
        XCTAssertNil(sut)
    }
    
    func testDoubleNullWithValueAndError() {
        let sut: Swift.Result<Any?, Error>? = Swift.Result(0, "Error")
        
        switch sut {
        case .failure(let error): XCTAssertEqual(error as? String, "Error")
        default:
            XCTFail("Result should be .failure(Double NULL)")
        }
    }
    
    func testDoubleNullWithError() {
        let sut: Swift.Result<Any?, Error>? = Swift.Result(nil, "Error")
        
        switch sut {
        case .failure(let error): XCTAssertEqual(error as? String, "Error")
        default:
            XCTFail("Result should be .failure(Double NULL)")
        }
    }
    
    func testDoubleNullWithValue() {
        let sut: Swift.Result<Int?, Error>? = Swift.Result(0, nil)
        
        switch sut {
        case .success(let value): XCTAssertEqual(value, 0)
        default:
            XCTFail("Result should be .failure(Double NULL)")
        }
    }

    // Helper

    func throwing() throws -> Bool {
        throw "fixture throw"
    }

    func nonThrowing() throws -> Bool {
        return true
    }
}
