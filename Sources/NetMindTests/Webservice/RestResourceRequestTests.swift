//
//  RestResourceRequestTests.swift
//  NetMindTests
//
//  Created by Martin Gratzer on 15.10.17.
//  Copyright © 2017 topmind mobile app solutions. All rights reserved.
//

import XCTest
@testable import NetMind

final class RestResourceRequestTests: XCTestCase {

    func testResourcePaths(){
        var sut = givenGet()
        XCTAssertEqual("fixture 123", sut.path)

        sut = givenCreate()
        XCTAssertEqual("", sut.path)

        sut = givenUpdate()
        XCTAssertEqual("fixture 123", sut.path)

        sut = givenDelete()
        XCTAssertEqual("fixture 123", sut.path)
    }

    func testResourceMethods(){
        var sut = givenGet()
        XCTAssertEqual(.get, sut.method)

        sut = givenCreate()
        XCTAssertEqual(.post, sut.method)

        sut = givenUpdate()
        XCTAssertEqual(.put, sut.method)

        sut = givenDelete()
        XCTAssertEqual(.delete, sut.method)
    }

    func testResourceParameters(){
        var sut = givenGet()
        XCTEqualAnyDictionaryWithValuesOfString([:], sut.queryParameters)

        sut = givenCreate()
        XCTAssertEqual(try JSONEncoder().encode(givenUser()), try sut.encode(with: JsonWebserviceFormat())?.get())

        sut = givenUpdate()
        XCTAssertEqual(try JSONEncoder().encode(givenUser()), try sut.encode(with: JsonWebserviceFormat())?.get())

        sut = givenDelete()
        XCTEqualAnyDictionaryWithValuesOfString([:], sut.queryParameters)
    }

    // TestHelper
    func givenGet() -> RestResourceRequest<UserResource, String> {
        return .get(id: givenUser().id)
    }

    func givenCreate() -> RestResourceRequest<UserResource, String> {
        let user = givenUser()
        return .create(user)
    }

    func givenUpdate() -> RestResourceRequest<UserResource, String> {
        let user = givenUser()
        return .update(id: user.id, user)
    }

    func givenDelete() -> RestResourceRequest<UserResource, String> {
        return .delete(id: givenUser().id)
    }

    func givenUser() -> UserResource {
        return UserResource(id: "fixture 123", name: "fixture name")
    }

    func XCTEqualAnyDictionaryWithValuesOfString(_ a: Dictionary<String, Any>,
                                                 _ b: Dictionary<String, Any>,
                                                 file: String = #file,
                                                 line: UInt = #line) {

        if a.isEmpty && b.isEmpty {
            return
        }

        if a.keys.count != b.keys.count {
            recordFailure(withDescription: "a.keys != b.keys", inFile: file, atLine: Int(line), expected: false)
            return
        }

        if a.keys.sorted() != b.keys.sorted() {
            recordFailure(withDescription: "a.keys != b.keys", inFile: file, atLine: Int(line), expected: false)
            return
        }

        let aValues = (a.compactMap { $0.value as? String })
        let bValues = (b.compactMap { $0.value as? String })

        if aValues != bValues {
            recordFailure(withDescription: "a.values != b.value", inFile: file, atLine: Int(line), expected: false)
            return
        }
    }
}

struct UserResource: Codable {
    let id: String
    let name: String
}
