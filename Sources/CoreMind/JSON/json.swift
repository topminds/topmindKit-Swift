//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public typealias JSONArray = [Any]
public typealias JSONObject = [String: Any]

public enum JSON {
	case array(JSONArray)
	case object(JSONObject)
	case objects([JSONObject])

	public init(json: Any) throws {
		if let object = json as? JSONObject {
			self = .object(object)
		} else if let objects = json as? [JSONObject] {
			self = .objects(objects)
		} else if let array = json as? JSONArray {
			self = .array(array)
		} else {
			throw JSONError.invalidType(receivedValue: json)
		}
	}

	public init(string: String) throws {
		guard let data = string.data(using: .utf8) else {
			throw JSONError.invalidType(receivedValue: string)
		}
		try self.init(data: data)
	}

	public init(stream: InputStream) throws {
		let json = try JSONSerialization.jsonObject(with: stream,
		                                            options: [])
		try self.init(json: json)
	}

	public init(data: Data) throws {
		let json = try JSONSerialization.jsonObject(with: data, options: [])
		try self.init(json: json)
	}
}

public protocol JSONDecodable {
	mutating func update(with json: JSONObject) throws
}

/// Note: Consider using Codable in Swift 4+
public protocol JSONDeserializable {
	init(json: JSONObject) throws
}

public extension JSON {
	var json: Any {
		switch self {
		case let .array(array): return array
		case let .object(object): return object
		case let .objects(objects): return objects
		}
	}

	var array: Swift.Result<JSONArray, Error> {
		guard case let .array(array) = self else {
			return .failure(JSONError.invalidType(receivedValue: type(of: self)))
		}
		return .success(array)
	}

	var object: Swift.Result<JSONObject, Error> {
		guard case let .object(object) = self else {
			return .failure(JSONError.invalidType(receivedValue: type(of: self)))
		}
		return .success(object)
	}

	var objects: Swift.Result<[JSONObject], Error> {
		guard case let .objects(objects) = self else {
			return .failure(JSONError.invalidType(receivedValue: type(of: self)))
		}
		return .success(objects)
	}

	var data: Swift.Result<Data, Error> {
		Swift.Result {
			try JSONSerialization.data(withJSONObject: json, options: [])
		}
	}

	func parse<U: JSONDeserializable>() -> Swift.Result<U, Error> {
		object.flatMap {
			object in
			Swift.Result { try U(json: object) }
		}
	}

	func parse<U: JSONDeserializable>() -> Swift.Result<[U], Error> {
		objects.flatMap {
			objects in
			Swift.Result { try objects.map { try U(json: $0) } }
		}
	}

	func parse<U: Decodable>() -> Swift.Result<U, Error> {
		data.parse()
	}

	// parse is not working, hmm...
	func parseList<U: Decodable>() -> Swift.Result<[U], Error> {
		data.parse()
	}
}
