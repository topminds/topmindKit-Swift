//
//  DateDecoding.swift
//  CoreMind
//
//  Created by Martin Gratzer on 11.03.19.
//  Copyright © 2019 topmind mobile app solutions. All rights reserved.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {

    public static func keySpecific(_ formatterForKey: @escaping (CodingKey) throws -> DateFormatter?) -> JSONDecoder.DateDecodingStrategy {
        return .custom({ (decoder) -> Date in
            guard let codingKey = decoder.codingPath.last else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No Coding Path Found"))
            }

            guard let container = try? decoder.singleValueContainer(),
                let text = try? container.decode(String.self) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode date text"))
            }

            guard let dateFormatter = try formatterForKey(codingKey) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "No date formatter for date text")
            }

            if let date = dateFormatter.date(from: text) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(text)")
            }
        })
    }
}

extension JSONEncoder.DateEncodingStrategy {

    public static func keySpecific(_ formatterForKey: @escaping (CodingKey) throws -> DateFormatter?) -> JSONEncoder.DateEncodingStrategy {

        return .custom({ date, encoder in
            guard let codingKey = encoder.codingPath.last else {
                throw EncodingError.invalidValue(date, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "No Coding Path Found"))
            }

            var container = encoder.singleValueContainer()

            guard let dateFormatter = try formatterForKey(codingKey) else {
                throw EncodingError.invalidValue(date, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "No date formatter found"))
            }

            try container.encode(dateFormatter.string(from: date))

        })
    }
}
