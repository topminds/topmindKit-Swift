//
//  JsonWebserviceFormat.swift
//  NetMind
//
//  Created by Martin Gratzer on 30.08.18.
//  Copyright © 2018 topmind mobile app solutions. All rights reserved.
//

import Foundation

public struct JsonWebserviceFormat: WebserviceFormat {

    public static let httpHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]

    public init() { }

    public func serialize<T>(encodable: T) -> Result<Data, Error> where T : Encodable {
        return Result { try JSONEncoder().encode(encodable) }
    }

    @available(iOS 10.0, *)
    public func serialize<T>(encodable: T, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .iso8601) -> Result<Data, Error> where T : Encodable {
        return Result {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = dateEncodingStrategy
            return try encoder.encode(encodable)
        }
    }

    public func deserialize<T>(decodable: Data) -> Result<T, Error> where T : Decodable {
        return Result { try JSONDecoder().decode(T.self, from: decodable) }
    }

    @available(iOS 10.0, *)
    public func deserialize<T>(decodable: Data, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) -> Result<T, Error> where T : Decodable {
        return Result {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            return try decoder.decode(T.self, from: decodable)
        }
    }
}
