//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

// MARK: Jsondeserializable

@available(*, deprecated, message: "use json.decode() method")
public func decode<T: JSONDeserializable>(json: JSONObject) throws -> T {
	try json.decode()
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode<T: JSONDeserializable>(json: JSONObject, key: String) throws -> [T] {
	try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decodeStrict<T: JSONDeserializable>(json: JSONObject, key: String) throws -> [T] {
	try json.decodeStrict(key: key)
}

// MARK: primitive data type decoding

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> Int {
	try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> UInt {
	try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> Int8 {
	try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> UInt8 {
	try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> Int16 {
	try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> UInt16 {
	try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> Int32 {
	try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> UInt32 {
	try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> Int64 {
	try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> UInt64 {
	try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> Float {
	try json.decode(key: key)
}

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> Double {
	try json.decode(key: key)
}

// MARK: date decoding

@available(*, deprecated, message: "Please switch to `json.decode(key:format:)` method.")
public func decode(json: JSONObject, key: String, format: String? = nil) throws -> Date {
	try json.decode(key: key, format: format)
}

// MARK: url decoding

@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode(json: JSONObject, key: String) throws -> URL {
	try json.decode(key: key)
}

// MARK: RawRepresentable

/*  T.RawValue is concrete due to ambiguity issues */
@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode<T: RawRepresentable>(json: JSONObject, key: String) throws -> T
	where T.RawValue == String {
	try json.decode(key: key)
}

/*  T.RawValue is concrete due to ambiguity issues */
@available(*, deprecated, message: "Please switch to `json.decode(key:)` method.")
public func decode<T: RawRepresentable>(json: JSONObject, key: String) throws -> T
	where T.RawValue == Int {
	try json.decode(key: key)
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
