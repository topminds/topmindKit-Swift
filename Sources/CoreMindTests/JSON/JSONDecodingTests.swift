//
//  jsonTests.swift
//  topmindKit
//
//  Created by Martin Gratzer on 24/09/2016.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
//

import XCTest
@testable import CoreMind

enum DummyIntEnum: Int {
    case A, B, C
}

enum DummyEnum: String {
    case A, B, C
}

struct Dummy: Equatable, JSONDeserializable {
    let name: String
    let nameOptional: String?
    let createdAt: Date
    let createdAtOptional: Date?
    let url: URL?

    init(name: String, createdAt: Date, url: URL?) {
        self.name = name
        self.nameOptional = name
        self.createdAt = createdAt
        self.createdAtOptional = createdAt
        self.url = url
    }

    init(json: JSONObject) throws {
        name = try json.decode(key: "name")
        nameOptional = try json.decodeIfPresent(key: "name_optional")
        createdAt = try json.decode(key: "created_at")
        createdAtOptional = try json.decodeIfPresent(key: "created_at_optional")
        
        do {
            let url: URL = try json.decode(key: "url")
            self.url = url
        } catch {
            url = nil
        }
    }

    static func ==(lhs: Dummy, rhs: Dummy) -> Bool {
        return lhs.name == rhs.name &&
            lhs.createdAt == rhs.createdAt &&
            lhs.url == rhs.url
    }
}

final class jsonTests: XCTestCase {

    let date = Date(timeIntervalSince1970: 1474576117)
    let dummy = Dummy(name: "Fixture",
                      createdAt: Date(timeIntervalSince1970: 1474576117),
                      url: URL(string: "http://www.topmind.eu"))

    func testStringArrayDeserialization() throws {
        let json: [String: Any] = ["array": ["A", "B", "C"]]

        let dummy: [String] = try json.decode(key: "array")
        XCTAssertEqual(dummy, ["A", "B", "C"])
    }
    
    func testStringArrayOptionalDeserialization() throws {
        let json: [String: Any] = ["array": ["A", "B", "C"]]

        let dummy: [String]? = try json.decodeIfPresent(key: "array")
        XCTAssertEqual(dummy, ["A", "B", "C"])
    }

    func testIntArrayDeserialization() throws {
        let json: [String: Any] = ["array": [1, 2, 3]]

        let dummy: [Int] = try json.decode(key: "array")
        XCTAssertEqual(dummy, [1, 2, 3])
    }
    
    func testIntArrayOptionalDeserialization() throws {
        let json: [String: Any] = ["array": [1, 2, 3]]

        let dummy: [Int]? = try json.decodeIfPresent(key: "array")
        XCTAssertEqual(dummy, [1, 2, 3])
    }

    func testDeserialization() throws {
        do {
            let json: [String: Any] = givenDummyPayload()

            let sut: Dummy = try json.decode()

            XCTAssertEqual(sut, dummy)
        } catch {
            print(error)
        }

    }

    func testDeserializationNested() throws {
        let json: [String: Any] = ["dummy": givenDummyPayload()]
        

        let sut: Dummy = try json.decode(key: "dummy")

        XCTAssertEqual(sut, dummy)
    }

    func testUrlDeserialization() throws {
        let json: [String: Any] = [
            "url": "http://topmind.eu"
        ]

        let sut: URL = try json.decode(key: "url")

        XCTAssertEqual(sut, URL(string: "http://topmind.eu"))
    }
    
    func testUrlDeserializationWithEncodingIssues() throws {
        let json: [String: Any] = [
            "url": "http://topmind.eu/this is a bad path/"
        ]
        
        let sut: URL = try json.decode(key: "url")
        
        XCTAssertEqual(sut, URL(string: "http://topmind.eu/this%20is%20a%20bad%20path/"))
    }

    func testStringDeserialization() throws {
        let json: [String: Any] = [
            "string": "string"
        ]

        let sut: String = try json.decode(key: "string")
        XCTAssertEqual("string", sut)
    }
    
    func testStringOptionalWithValueDeserialization() throws {
        let json: [String: Any] = [
            "string": "string"
        ]

        let sut: String? = try json.decodeIfPresent(key: "string")
        XCTAssertEqual("string", sut)
    }
    
    func testStringOptionalWithNullDeserialization() throws {
        let json: [String: Any] = [
            "string": NSNull()
        ]

        let sut: String? = try json.decodeIfPresent(key: "string")
        XCTAssertNil(sut)
    }
    
    func testStringOptionalMissingDeserialization() throws {
        let json: [String: Any] = [:]

        let sut: String? = try json.decodeIfPresent(key: "string")
        XCTAssertNil(sut)
    }
    
    func testIntDeserialization() throws {
        let json: [String: Any] = [
            "num": 123.321
        ]

        let sut: Int = try json.decode(key: "num")
        XCTAssertEqual(123, sut)
    }
    
    func testIntOptionalWithValueDeserialization() throws {
        let json: [String: Any] = [
            "num": 123.321
        ]

        let sut: Int? = try json.decodeIfPresent(key: "num")
        XCTAssertEqual(123, sut)
    }

    func testUIntDeserialization() throws {
        let json: [String: Any] = [
            "num": 123.321
        ]

        let sut: UInt = try json.decode(key: "num")
        XCTAssertEqual(123, sut)
    }
    
    func testUIntOptionalDeserialization() throws {
        do {
            let json: [String: Any] = [
                "num": 123.321
            ]

            let sut: UInt? = try json.decodeIfPresent(key: "num")
            XCTAssertEqual(123, sut)
        } catch {
            throw error
        }
    }

    func testInt8Deserialization() throws {
        let json: [String: Any] = [
            "num": 123.321
        ]

        let sut: Int8 = try json.decode(key: "num")
        XCTAssertEqual(123, sut)
    }
    
    func testInt8OptionalDeserialization() throws {
        let json: [String: Any] = [
            "num": 123.321
        ]

        let sut: Int8? = try json.decodeIfPresent(key: "num")
        XCTAssertEqual(123, sut)
    }

    func testUInt8Deserialization() throws {
        let json: [String: Any] = [
            "num": 123.321
        ]

        let sut: UInt8 = try json.decode(key: "num")
        XCTAssertEqual(123, sut)
    }

    func testUInt8OptionalDeserialization() throws {
        let json: [String: Any] = [
            "num": 123.321
        ]

        let sut: UInt8? = try json.decodeIfPresent(key: "num")
        XCTAssertEqual(123, sut)
    }

    func testInt16Deserialization() throws {
        let json: [String: Any] = [
            "num": 123.321
        ]
        
        let sut: Int16 = try json.decode(key: "num")
        
        XCTAssertEqual(123, sut)
    }
    
    func testInt16OptionalDeserialization() throws {
        let json: [String: Any] = [
            "num": 123.321
        ]
        
        let sut: Int16? = try json.decodeIfPresent(key: "num")
        
        XCTAssertEqual(123, sut)
    }

    func testUInt16Deserialization() throws {
        let json: [String: Any] = [
            "num": 123.321
        ]

        let sut: UInt16 = try json.decode(key: "num")

        XCTAssertEqual(123, sut)
    }
    
    func testUInt16OptionalDeserialization() throws {
        let json: [String: Any] = [
            "num": 123.321
        ]

        let sut: UInt16? = try json.decodeIfPresent(key: "num")

        XCTAssertEqual(123, sut)
    }
    
    func testInt32Deserialization() throws {
        let json: [String: Any] = [
            "num": 1234.3214
        ]
        
        let sut: Int32 = try json.decode(key: "num")
        
        XCTAssertEqual(1234, sut)
    }
    
    func testInt32OptionalDeserialization() throws {
        let json: [String: Any] = [
            "num": 1234.3214
        ]
        
        let sut: Int32? = try json.decodeIfPresent(key: "num")
        
        XCTAssertEqual(1234, sut)
    }

    func testUInt32Deserialization() throws {
        let json: [String: Any] = [
            "num": 1234.3214
        ]

        let sut: UInt32 = try json.decode(key: "num")

        XCTAssertEqual(1234, sut)
    }
    
    func testUInt32OptionalDeserialization() throws {
        let json: [String: Any] = [
            "num": 1234.3214
        ]

        let sut: UInt32? = try json.decodeIfPresent(key: "num")

        XCTAssertEqual(1234, sut)
    }

    func testInt64Deserialization() throws {
        let json: [String: Any] = [
            "num": 123456.321456
        ]

        let sut: Int64 = try json.decode(key: "num")

        XCTAssertEqual(123456, sut)
    }
    
    func testInt64OptionalDeserialization() throws {
        let json: [String: Any] = [
            "num": 123456.321456
        ]

        let sut: Int64? = try json.decodeIfPresent(key: "num")

        XCTAssertEqual(123456, sut)
    }

    func testUInt64Deserialization() throws {
        let json: [String: Any] = [
            "num": 123456.321456
        ]

        let sut: UInt64 = try json.decode(key: "num")

        XCTAssertEqual(123456, sut)
    }
    
    func testUInt64OptionalDeserialization() throws {
        let json: [String: Any] = [
            "num": 123456.321456
        ]

        let sut: UInt64? = try json.decodeIfPresent(key: "num")

        XCTAssertEqual(123456, sut)
    }
    
    func testFloatDeserializationWithWholeValue() throws {
        let json: [String: Any] = [
            "num": 123.321456
        ]
        
        let sut: Float = try json.decode(key: "num")
        
        XCTAssertEqual(123.321456, sut)
    }
    
    func testFloatOptionalDeserializationWithWholeValue() throws {
        let json: [String: Any] = [
            "num": 123.321456
        ]
        
        let sut: Float? = try json.decodeIfPresent(key: "num")
        
        XCTAssertEqual(123.321456, sut)
    }
    
    func testFloatDeserializationWithDoubleValue() throws {
        let json: [String: Any] = [
            "num": 123456.1234567891
        ]
        
        let sut: Float = try json.decode(key: "num")
        
        XCTAssertEqual(123456.1234567891, sut)
    }
    
    func testFloatOptionalDeserializationWithDoubleValue() throws {
        let json: [String: Any] = [
            "num": 123456.1234567891
        ]
        
        let sut: Float? = try json.decodeIfPresent(key: "num")
        
        XCTAssertEqual(123456.1234567891, sut)
    }
    
    func testDoubleDeserializationWithWholeValue() throws {
        let json: [String: Any] = [
            "num": 123.321456
        ]
        
        let sut: Double = try json.decode(key: "num")
        
        XCTAssertEqual(123.321456, sut)
    }
    
    func testDoubleOptionalDeserializationWithWholeValue() throws {
        let json: [String: Any] = [
            "num": 123.321456
        ]
        
        let sut: Double? = try json.decodeIfPresent(key: "num")
        
        XCTAssertEqual(123.321456, sut)
    }
    
    func testDoubleDeserializationWithDoubleValue() throws {
        let json: [String: Any] = [
            "num": 123456.1234567891
        ]
        
        let sut: Double = try json.decode(key: "num")
        
        XCTAssertEqual(123456.1234567891, sut)
    }
    
    func testDoubleOptionalDeserializationWithDoubleValue() throws {
        let json: [String: Any] = [
            "num": 123456.1234567891
        ]
        
        let sut: Double? = try json.decodeIfPresent(key: "num")
        
        XCTAssertEqual(123456.1234567891, sut)
    }

    func testUrlOptionalDeserializationWithIncorrectValue() throws {
        var json: [String: Any] = givenDummyPayload()
        json["url"] = ""
        
        let dummy: Dummy = try json.decode()

        XCTAssertNotNil(dummy)
        XCTAssertNil(dummy.url)
    }

    func testOptionalDeserializationWithMissingValue() throws {
        do {
            let json: [String: Any] = givenDummyPayload(optional: true)

            let dummy: Dummy = try json.decode()

            XCTAssertNotNil(dummy)
            XCTAssertNil(dummy.nameOptional)
            XCTAssertNil(dummy.createdAtOptional)
            XCTAssertNil(dummy.url)
        } catch {
            print(error)
            XCTFail()
        }
    }

    func testObjectArrayDeserialization() throws {
        let json: [String: Any] = [ "array": [
                        givenDummyPayload(name: "Fixture 1"),
                        givenDummyPayload(name: "Fixture 2")
                    ]
        ]

        let dummy: [Dummy] = try json.decode(key: "array")
        XCTAssertEqual(dummy.map { $0.name }, ["Fixture 1", "Fixture 2"])
    }

    func testObjectArrayDeserializationStrictShouldFail() {
        let json: [String: Any] = [ "array": [
            ["created_at": "2016-09-22T22:28:37+02:00"],
            ["name": "Fixture 2", "created_at": "2016-09-22T22:28:37+02:00"]
            ]
        ]

        do {
            let _: [Dummy] = try json.decodeStrict(key: "array")
            XCTFail("Strict parsing should fail")
        } catch {
            // all good
        }
    }

    func testObjectArrayDeserializationNonStrictShouldIgnoreFailing() throws {
        let json: [String: Any] = [ "array": [
            [ "created_at": "2016-09-22T22:28:37+02:00"],
            givenDummyPayload(name: "Fixture 2")
            ]
        ]

        let dummy: [Dummy] = try json.decode(key: "array")
        XCTAssertEqual(dummy.map { $0.name }, ["Fixture 2"])
    }

    func testObjectArrayDeserializationNonStrictShouldIgnoreIncorrectArrayType() throws {
        let json: [String: Any] = [ "array": NSNull() ]

        let dummy: [Dummy] = try json.decode(key: "array")
        XCTAssertEqual(dummy, [])
    }

    func testStringEnumDeserialization() throws {
        let json: [String: Any] = ["enumvalue": "A"]

        let dummy: DummyEnum = try json.decode(key: "enumvalue")
        XCTAssertEqual(dummy, .A)
    }

    func testStringEnumArrayDeserialization() throws {
        let json: [String: Any] = ["enumvalues": ["A", "B", "C"]]

        let dummy: [DummyEnum] = try json.decode(key: "enumvalues")
        XCTAssertEqual(dummy, [.A, .B, .C])
    }
    
    func testStringEnumArrayOptionalDeserialization() throws {
        let json: [String: Any] = ["enumvalues": ["A", "B", "C"]]

        let dummy: [DummyEnum]? = try json.decodeIfPresent(key: "enumvalues")
        XCTAssertEqual(dummy, [.A, .B, .C])
    }

    func testIntEnumDeserialization() throws {
        let json: [String: Any] = ["enumvalue": 0]

        let dummy: DummyIntEnum = try json.decode(key: "enumvalue")
        XCTAssertEqual(dummy, .A)
    }

    func testIntEnumArrayDeserialization() throws {
        let json: [String: Any] = ["enumvalues": [0, 1, 2]]

        let dummy: [DummyIntEnum] = try json.decode(key: "enumvalues")
        XCTAssertEqual(dummy, [.A, .B, .C])
    }
    
    func testIntEnumArrayOptionalDeserialization() throws {
        let json: [String: Any] = ["enumvalues": [0, 1, 2]]

        let dummy: [DummyIntEnum]? = try json.decodeIfPresent(key: "enumvalues")
        XCTAssertEqual(dummy, [.A, .B, .C])
    }

    func testISO8601() throws {
        let json: [String: Any] = [
            "timezone": "2016-09-22T22:28:37+02:00",
            "utc": "2016-09-22T20:28:37Z",
            "skiline": "2016-09-22T22:28:37.000+02:00"
        ]

        XCTAssertEqual(try json.decode(key: "timezone"), date)
        XCTAssertEqual(try json.decode(key: "utc"), date)
    }

    func testDateWithCustomFormat() throws {
        let json: JSONObject = [
            "timezone": "2016-09-22T22:28:37+02:00",
            "utc": "2016-09-22T20:28:37Z",
            "skiline": "2016-09-22T22:28:37.000+02:00"
        ]

        XCTAssertEqual(try json.decode(key: "timezone"), date)
        XCTAssertEqual(try json.decode(key: "utc"), date)
        XCTAssertEqual(try json.decode(key: "skiline", format: "yyyy-MM-dd'T'HH:mm:ss.000XXXXX"), date)
    }

    func testUnixTimestamp() throws {
        let json: [String: Any] = [
            "timestamp": 1474576117
        ]
        
        XCTAssertEqual(try json.decode(key: "timestamp"), date)
    }
    
    func givenDummyPayload(name: String = "Fixture", optional: Bool = false) -> [String: Any] {
        return [
            "name": name,
            "name_optional": !optional ? name : NSNull(),
            "created_at": "2016-09-22T22:28:37+02:00",
            "created_at_optional": !optional ? "2016-09-22T22:28:37+02:00" : NSNull(),
            "url": !optional ? "http://www.topmind.eu" : ""
        ]
    }
}
