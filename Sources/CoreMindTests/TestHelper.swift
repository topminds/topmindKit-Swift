//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

@testable import CoreMind
import XCTest

struct ParseOk: JSONDeserializable {
	init(json _: JSONObject) throws {}
}

struct ParseNok: JSONDeserializable {
	init(json _: JSONObject) throws {
		throw "nok"
	}
}
