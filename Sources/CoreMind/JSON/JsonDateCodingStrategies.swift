//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public extension JSONDecoder.DateDecodingStrategy {
	static func keySpecific(_ formatterForKey: @escaping (CodingKey) throws -> DateFormatter?) -> JSONDecoder.DateDecodingStrategy {
		.custom { decoder -> Date in
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
		}
	}
}

public extension JSONEncoder.DateEncodingStrategy {
	static func keySpecific(_ formatterForKey: @escaping (CodingKey) throws -> DateFormatter?) -> JSONEncoder.DateEncodingStrategy {
		.custom { date, encoder in
			guard let codingKey = encoder.codingPath.last else {
				throw EncodingError.invalidValue(date, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "No Coding Path Found"))
			}

			var container = encoder.singleValueContainer()

			guard let dateFormatter = try formatterForKey(codingKey) else {
				throw EncodingError.invalidValue(date, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "No date formatter found"))
			}

			try container.encode(dateFormatter.string(from: date))
		}
	}
}
