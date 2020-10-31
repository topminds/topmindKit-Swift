//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public enum JSONError: Error {
    case missingAttribute(key: String)
    case invalidAttributeType(key: String, expectedType: Any.Type, receivedValue: Any)
    case invalidAttribute(key: String)
    case invalidType(receivedValue: Any)
}

extension Sequence where Iterator.Element == (key: String, value: Any) {

    public func decodeIfPresent<T>(key: String) throws -> T? {
        guard let value = try valueIfPresent(for: key) else {
            return nil
        }

        guard let attribute = value as? T else {
            throw JSONError.invalidAttributeType(key: key,
                                                 expectedType: T.self,
                                                 receivedValue: value)
        }

        return attribute
    }
    
    public func decode<T>(key: String) throws -> T {
        guard let attribute = try value(for: key) as? T else {
            throw JSONError.invalidAttributeType(key: key,
                                                 expectedType: T.self,
                                                 receivedValue: value)
        }

        return attribute
    }
    
    // MARK: JSONDeserializable

    public func decode<T: JSONDeserializable>() throws -> T {

        guard let json = self as? JSONObject else {
            throw JSONError.invalidType(receivedValue: type(of: self))
        }

        return try T.init(json: json)
    }

    public func decodeIfPresent<T: JSONDeserializable>(key: String) throws -> T? {
        guard let value = try valueIfPresent(for: key) else {
            return nil
        }
        
        guard let attribute = value as? JSONObject else {
            throw JSONError.invalidAttributeType(key: key,
                                                 expectedType: T.self,
                                                 receivedValue: value)
        }

        return try T.init(json: attribute)
    }
    
    public func decode<T: JSONDeserializable>(key: String) throws -> T {
        guard let attribute = try value(for: key) as? JSONObject else {
            throw JSONError.invalidAttributeType(key: key,
                                                 expectedType: T.self,
                                                 receivedValue: value)
        }

        return try T.init(json: attribute)
    }

    // MARK: Array
    
    public func decodeIfPresent<T: JSONDeserializable>(key: String) throws -> [T]? {
        guard let value = try valueIfPresent(for: key) else {
            return nil
        }

        guard let array = value as? [JSONObject] else {
            return []
        }

        return array.compactMap { try? T(json: $0) }
    }
    
    public func decode<T: JSONDeserializable>(key: String) throws -> [T] {
        guard let json = self as? JSONObject else {
            throw JSONError.invalidType(receivedValue: type(of: self))
        }

        guard let array = json[key] as? [JSONObject] else {
            return []
        }

        return array.compactMap { try? T(json: $0) }
    }

    public func decodeStrict<T: JSONDeserializable>(key: String) throws -> [T] {

        guard let json = self as? JSONObject else {
            throw JSONError.invalidType(receivedValue: type(of: self))
        }

        guard let array = json[key] as? [JSONObject] else {
            throw JSONError.invalidAttributeType(key: key,
                                                 expectedType: [T].self,
                                                 receivedValue: json)
        }

        return try array.map { try T(json: $0) }
    }

    // MARK: primitive data type decodingIfPresent
    
    public func decodeIfPresent(key: String) throws -> Int? {
        let number: NSNumber? = try decodeIfPresent(key: key)
        return number?.intValue
    }
    
    public func decodeIfPresent(key: String) throws -> UInt? {
        let number: NSNumber? = try decodeIfPresent(key: key)
        return number?.uintValue
    }
    
    public func decodeIfPresent(key: String) throws -> Int8? {
        let number: NSNumber? = try decodeIfPresent(key: key)
        return number?.int8Value
    }

    public func decodeIfPresent(key: String) throws -> UInt8? {
        let number: NSNumber? = try decodeIfPresent(key: key)
        return number?.uint8Value
    }

    public func decodeIfPresent(key: String) throws -> Int16? {
        let number: NSNumber? = try decodeIfPresent(key: key)
        return number?.int16Value
    }

    public func decodeIfPresent(key: String) throws -> UInt16? {
        let number: NSNumber? = try decodeIfPresent(key: key)
        return number?.uint16Value
    }

    public func decodeIfPresent(key: String) throws -> Int32? {
        let number: NSNumber? = try decodeIfPresent(key: key)
        return number?.int32Value
    }

    public func decodeIfPresent(key: String) throws -> UInt32? {
        let number: NSNumber? = try decodeIfPresent(key: key)
        return number?.uint32Value
    }

    public func decodeIfPresent(key: String) throws -> Int64? {
        let number: NSNumber? = try decodeIfPresent(key: key)
        return number?.int64Value
    }

    public func decodeIfPresent(key: String) throws -> UInt64? {
        let number: NSNumber? = try decodeIfPresent(key: key)
        return number?.uint64Value
    }

    public func decodeIfPresent(key: String) throws -> Float? {
        let number: NSNumber? = try decodeIfPresent(key: key)
        return number?.floatValue
    }

    public func decodeIfPresent(key: String) throws -> Double? {
        let number: NSNumber? = try decodeIfPresent(key: key)
        return number?.doubleValue
    }
    
    // MARK: primitive data type decoding
        
    public func decode(key: String) throws -> Int {
        let number: NSNumber = try decode(key: key)
        return number.intValue
    }
    
    public func decode(key: String) throws -> UInt {
        let number: NSNumber = try decode(key: key)
        return number.uintValue
    }
    
    public func decode(key: String) throws -> Int8 {
        let number: NSNumber = try decode(key: key)
        return number.int8Value
    }

    public func decode(key: String) throws -> UInt8 {
        let number: NSNumber = try decode(key: key)
        return number.uint8Value
    }

    public func decode(key: String) throws -> Int16 {
        let number: NSNumber = try decode(key: key)
        return number.int16Value
    }

    public func decode(key: String) throws -> UInt16 {
        let number: NSNumber = try decode(key: key)
        return number.uint16Value
    }

    public func decode(key: String) throws -> Int32 {
        let number: NSNumber = try decode(key: key)
        return number.int32Value
    }

    public func decode(key: String) throws -> UInt32 {
        let number: NSNumber = try decode(key: key)
        return number.uint32Value
    }

    public func decode(key: String) throws -> Int64 {
        let number: NSNumber = try decode(key: key)
        return number.int64Value
    }

    public func decode(key: String) throws -> UInt64 {
        let number: NSNumber = try decode(key: key)
        return number.uint64Value
    }

    public func decode(key: String) throws -> Float {
        let number: NSNumber = try decode(key: key)
        return number.floatValue
    }

    public func decode(key: String) throws -> Double {
        let number: NSNumber = try decode(key: key)
        return number.doubleValue
    }
    
    // MARK: date decoding

    public func decodeIfPresent(key: String, format: String? = nil) throws -> Date? {
        guard let value = try valueIfPresent(for: key) else {
            return nil
        }
        let date: Date = try decode(key: key, value: value, format: format)
        return date
    }
    
    public func decode(key: String, format: String? = nil) throws -> Date {
        let date: Date = try decode(key: key, value: try value(for: key), format: format)
        return date
    }
    
    public func decode(key: String, value: Any, format: String?) throws -> Date {
        if let string = value as? String {
            if format == nil {
                guard let date = ISO8601DateFormatter().date(from: string) else {
                    throw JSONError.invalidAttribute(key: key)
                }
                return date
            } else {
                /// xcdoc://?url=developer.apple.com/library/content/qa/qa1480/_index.html
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = format ?? "yyyy-MM-dd'T'HH:mm:ssXXXXX"
                guard let date = formatter.date(from: string) else {
                    throw JSONError.invalidAttribute(key: key)
                }
                return date
            }
        }

        if let timeInterval = value as? TimeInterval {
            return Date(timeIntervalSince1970: timeInterval)
        }

        if let timeInterval = value as? Int {
            return Date(timeIntervalSince1970: TimeInterval(timeInterval))
        }

        throw JSONError.invalidAttributeType(key: key, expectedType: String.self, receivedValue: value)
    }


    // MARK: url decoding

    public func decodeIfPresent(key: String) throws -> URL? {
        guard let urlString: String = try decodeIfPresent(key: key) else {
            return nil
        }
        
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: encodedUrlString) else {
                throw JSONError.invalidAttributeType(key: key, expectedType: URL.self, receivedValue: urlString)
        }

        return url
    }
    
    public func decode(key: String) throws -> URL {

        let urlString: String = try decode(key: key)

        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: encodedUrlString) else {
                throw JSONError.invalidAttributeType(key: key, expectedType: URL.self, receivedValue: urlString)
        }

        return url
    }


    // MARK: Raw Representables / Enums

    public func decodeIfPresent<T: RawRepresentable>(key: String) throws -> T? where T.RawValue == String {
        guard try valueIfPresent(for: key) != nil else {
            return nil
        }
        
        guard let json = self as? JSONObject else {
            throw JSONError.invalidType(receivedValue: type(of: self))
        }
        
        return try json.decodeEnum(key: key)
    }
    
    public func decode<T: RawRepresentable>(key: String) throws -> T where T.RawValue == String {
        guard let json = self as? JSONObject else {
            throw JSONError.invalidType(receivedValue: type(of: self))
        }

        return try json.decodeEnum(key: key)
    }
    
    /*  T.RawValue is concrete due to ambiguity issues */
    
    public func decodeIfPresent<T: RawRepresentable>(key: String) throws -> T? where T.RawValue == Int {
        guard try valueIfPresent(for: key) != nil else {
            return nil
        }
        
        guard let json = self as? JSONObject else {
            throw JSONError.invalidType(receivedValue: type(of: self))
        }

        return try json.decodeEnum(key: key)
    }
    
    public func decode<T: RawRepresentable>(key: String) throws -> T where T.RawValue == Int {
        guard let json = self as? JSONObject else {
            throw JSONError.invalidType(receivedValue: type(of: self))
        }

        return try json.decodeEnum(key: key)
    }
    
    public func decodeIfPresent<T: RawRepresentable>(key: String) throws -> [T]? {
        guard let value = try valueIfPresent(for: key) else {
            return nil
        }
        
        guard let array = value as? [T.RawValue] else {
            throw JSONError.invalidAttributeType(key: key,
                                                 expectedType: [T].self,
                                                 receivedValue: value)
        }

        return try array.map { try decodeEnum(value: $0, key: key) }
    }

    public func decode<T: RawRepresentable>(key: String) throws -> [T] {
        
        let v = try value(for: key)
        
        guard let array = v as? [T.RawValue] else {
            throw JSONError.invalidAttributeType(key: key,
                                                 expectedType: [T].self,
                                                 receivedValue: v)
        }

        return try array.map { try decodeEnum(value: $0, key: key) }
    }

    private func decodeEnum<T: RawRepresentable, U>(key: String) throws -> T
        where T.RawValue == U {

            let rawValue: U = try decode(key: key)
            return try decodeEnum(value: rawValue, key: key)
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
    
    // Helper
    
    private func decodeGenericIfPresent<T>(key: String) throws -> T? {
        guard let value = try valueIfPresent(for: key) else {
            return nil
        }

        guard let attribute = value as? T else {
            throw JSONError.invalidAttributeType(key: key,
                                                 expectedType: T.self,
                                                 receivedValue: value)
        }

        return attribute
    }
    
    private func decodeGeneric<T>(key: String) throws -> T {
        guard let attribute = try value(for: key) as? T else {
            throw JSONError.invalidAttributeType(key: key,
                                                 expectedType: T.self,
                                                 receivedValue: value)
        }

        return attribute
    }

    private func valueIfPresent(for key: String) throws -> Any? {
        guard let json = self as? JSONObject else {
            throw JSONError.invalidType(receivedValue: type(of: self))
        }
        
        guard (json[key] as? NSNull) == nil else {
            return nil
        }
        
        return json[key]
    }
    
    private func value(for key: String) throws  -> Any {
        guard let json = self as? JSONObject else {
            throw JSONError.invalidType(receivedValue: type(of: self))
        }
        
        guard let value = json[key] else {
            throw JSONError.missingAttribute(key: key)
        }
        
        return value
    }
}
