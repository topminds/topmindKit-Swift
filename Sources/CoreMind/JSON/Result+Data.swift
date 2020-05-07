//
//  Result+JSON.swift
//  topmindKit
//
//  Created by Martin Gratzer on 30/12/2016.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
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
