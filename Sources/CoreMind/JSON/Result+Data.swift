//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public extension Swift.Result {
	func parse<U: Decodable>() -> Swift.Result<U, Error> where Success == Data {
		Swift.Result<U, Error> {
			let jsonData = try resolve()
			return try JSONDecoder().decode(U.self, from: jsonData)
		}
	}

	func parse<U: Decodable>(key _: String) -> Swift.Result<[U], Error> where Success == Data {
		Swift.Result<[U], Error> {
			let jsonData = try resolve()
			return try JSONDecoder().decode([U].self, from: jsonData)
		}
	}
}
