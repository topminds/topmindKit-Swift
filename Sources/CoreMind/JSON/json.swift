//
//  json.swift
//  topmindKit
//
//  Created by Martin Gratzer on 24/09/2016.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
//

import Foundation

public typealias JSONArray = Array<Any>
public typealias JSONObject = Dictionary<String, Any>

@available(*, deprecated, message: "use JSONObject")
public typealias JSONDictionary = JSONObject

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

extension JSON {

    public var json: Any {
        switch self {
        case .array(let array): return array
        case .object(let object): return object
        case .objects(let objects): return objects
        }
    }

    public var array: Swift.Result<JSONArray, Error> {
        guard case .array(let array) = self else {
            return .failure(JSONError.invalidType(receivedValue: type(of: self)))
        }
        return .success(array)
    }

    public var object: Swift.Result<JSONObject, Error> {
        guard case .object(let object) = self else {
            return .failure(JSONError.invalidType(receivedValue: type(of: self)))
        }
        return .success(object)
    }

    public var objects: Swift.Result<[JSONObject], Error> {
        guard case .objects(let objects) = self else {
            return .failure(JSONError.invalidType(receivedValue: type(of: self)))
        }
        return .success(objects)
    }

    public var data: Swift.Result<Data, Error> {
        return Swift.Result {
            try JSONSerialization.data(withJSONObject: json, options: [])
        }
    }

    public func parse<U: JSONDeserializable>() -> Swift.Result<U, Error> {
        return object.flatMap {
            object in
            Swift.Result { try U(json: object) }
        }
    }

    public func parse<U: JSONDeserializable>() -> Swift.Result<[U], Error> {
        return objects.flatMap {
            objects in
            Swift.Result { try objects.map { try U(json: $0) } }
        }
    }

    public func parse<U: Decodable>() -> Swift.Result<U, Error> {
        return data.parse()
    }

    // parse is not working, hmm...
    public func parseList<U: Decodable>() -> Swift.Result<[U], Error> {
        return data.parse()
    }
}
