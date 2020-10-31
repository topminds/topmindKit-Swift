//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

extension Swift.Result {

    public func parse<U: JSONDeserializable>() -> Swift.Result<U, Error>
        where Success == JSONObject {
            return Swift.Result<U, Error> {
                let json = try resolve()
                return try U(json: json)
            }
    }

    public func parse<U: JSONDeserializable>(key: String) -> Swift.Result<[U], Error>
        where Success == JSONObject {
            return Swift.Result<[U], Error> {
                let json = try resolve()
                guard let list = json[key] as? [JSONObject] else {
                    throw "Incorrect JSON Type `\(self)`"
                }
                return try list.map { try U(json: $0) }
            }
    }

    public func parse<U>(key: String) -> Swift.Result<[U], Error>
        where Success == JSONObject {
            return Swift.Result<[U], Error> {
                 let json = try resolve()
                guard let list = json[key] as? [U] else {
                    throw "Incorrect JSON Type `\(self)`"
                }
                return list
            }
    }

    public func parse<U: JSONDeserializable>() -> Swift.Result<[U], Error>
        where Success == [JSONObject] {
            return Swift.Result<[U], Error> {
                let list = try resolve()
                return try list.map { try U(json: $0) }
            }
    }
}
