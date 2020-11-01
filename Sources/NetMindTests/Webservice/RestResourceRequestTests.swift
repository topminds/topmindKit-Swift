//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import XCTest
@testable import NetMind

final class RestResourceRequestTests: XCTestCase {

    func testResourcePaths() {
        var sut = givenGet()
        XCTAssertEqual("fixture 123", sut.path)

        sut = givenCreate()
        XCTAssertEqual("", sut.path)

        sut = givenUpdate()
        XCTAssertEqual("fixture 123", sut.path)

        sut = givenDelete()
        XCTAssertEqual("fixture 123", sut.path)
    }

    func testResourceMethods() {
        var sut = givenGet()
        XCTAssertEqual(.get, sut.method)

        sut = givenCreate()
        XCTAssertEqual(.post, sut.method)

        sut = givenUpdate()
        XCTAssertEqual(.put, sut.method)

        sut = givenDelete()
        XCTAssertEqual(.delete, sut.method)
    }

    func testResourceParameters() {
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

    func XCTEqualAnyDictionaryWithValuesOfString(_ a: [String: Any],
                                                 _ b: [String: Any],
                                                 file: String = #file,
                                                 line: UInt = #line) {

        let sourceCodeLocation = XCTSourceCodeLocation(filePath: file, lineNumber: Int(line))
        let sourceCodeContext = XCTSourceCodeContext(location: sourceCodeLocation)

        if a.isEmpty && b.isEmpty {
            return
        }

        if a.keys.count != b.keys.count {
            record(.init(type: .assertionFailure, compactDescription: "a.keys != b.keys", detailedDescription: nil, sourceCodeContext: sourceCodeContext, associatedError: nil, attachments: []))
            return
        }

        if a.keys.sorted() != b.keys.sorted() {
            record(.init(type: .assertionFailure, compactDescription: "a.keys.sorted() != b.keys.sorted()", detailedDescription: nil, sourceCodeContext: sourceCodeContext, associatedError: nil, attachments: []))
            return
        }

        let aValues = (a.compactMap { $0.value as? String })
        let bValues = (b.compactMap { $0.value as? String })

        if aValues != bValues {
            record(.init(type: .assertionFailure, compactDescription: "a.values != b.value", detailedDescription: nil, sourceCodeContext: sourceCodeContext, associatedError: nil, attachments: []))
            return
        }
    }
}

struct UserResource: Codable {
    let id: String
    let name: String
}
