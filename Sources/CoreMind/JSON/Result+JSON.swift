//
//  Result+JSON.swift
//  topmindKit
//
//  Created by Martin Gratzer on 30/12/2016.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
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
