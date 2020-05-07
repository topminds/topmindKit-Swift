//
//  CoreMindTests.swift
//  CoreMindTests
//
//  Created by Martin Gratzer on 23/08/2016.
//  Copyright © 2016 Martin Gratzer. All rights reserved.
//

import XCTest
@testable import CoreMind

struct ParseOk: JSONDeserializable {
    init(json: JSONObject) throws {

    }
}

struct ParseNok: JSONDeserializable {
    init(json: JSONObject) throws {
        throw "nok"
    }
}
