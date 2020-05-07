//
//  Compatibility.swift
//  topmindKit
//
//  Created by Martin Gratzer on 18/03/2017.
//  Copyright © 2017 topmind mobile app solutions. All rights reserved.
//

import Foundation

// MARK: Jsondeserializable
@available(*, deprecated, message: "use json.decode() method")
public func decode<T: JSONDeserializable>(json: JSONObject) throws -> T {
    return try json.decode()
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode<T: JSONDeserializable>(json: JSONObject, key: String) throws -> [T] {
    return try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decodeStrict<T: JSONDeserializable>(json: JSONObject, key: String) throws -> [T] {
    return try json.decodeStrict(key: key)
}

// MARK: primitive data type decoding
@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> Int {
    return try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> UInt {
    return try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> Int8 {
    return try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> UInt8 {
    return try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> Int16 {
    return try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> UInt16 {
    return try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> Int32 {
    return try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> UInt32 {
    return try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> Int64 {
    return try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> UInt64 {
    return try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> Float {
    return try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> Double {
    return try json.decode(key: key)
}


// MARK: date decoding
@available(*, deprecated, message: "Please switch to `json.decode(key:format:)` method.")
public func decode(json: JSONObject, key: String, format: String? = nil) throws -> Date {
    return try json.decode(key: key, format: format)
}


// MARK: url decoding
@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> URL {
    return try json.decode(key: key)
}


// MARK: RawRepresentable

/*  T.RawValue is concrete due to ambiguity issues */
@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode<T: RawRepresentable>(json: JSONObject, key: String) throws -> T
    where T.RawValue == String {

        return try json.decode(key: key)
}

/*  T.RawValue is concrete due to ambiguity issues */
@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode<T: RawRepresentable>(json: JSONObject, key: String) throws -> T
    where T.RawValue == Int {

        return try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode<T: RawRepresentable>(json: JSONObject, key: String) throws -> [T] {

    guard let array = json[key] as? [T.RawValue] else {
        throw JSONError.invalidAttributeType(key: key,
                                             expectedType: [T].self,
                                             receivedValue: json)
    }

    return try array.map { try decodeEnum(value: $0, key: key) }
}

private func decodeEnum<T: RawRepresentable, U>(value: U, key: String) throws -> T
    where T.RawValue == U {

        guard let enumValue = T(rawValue: value) else {
            throw JSONError.invalidAttributeType(key: key,
                                                 expectedType: T.self,
                                                 receivedValue: value)
        }
        return enumValue
}
