//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
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
