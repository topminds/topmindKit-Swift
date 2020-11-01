//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

extension Swift.Result {

    public func parse<U: Decodable>() -> Swift.Result<U, Error> where Success == Data {
        return Swift.Result<U, Error> {
            let jsonData = try resolve()
            return try JSONDecoder().decode(U.self, from: jsonData)
        }
    }

    public func parse<U: Decodable>(key: String) -> Swift.Result<[U], Error> where Success == Data {
        return Swift.Result<[U], Error> {
            let jsonData = try resolve()
            return try JSONDecoder().decode([U].self, from: jsonData)
        }
    }
}
