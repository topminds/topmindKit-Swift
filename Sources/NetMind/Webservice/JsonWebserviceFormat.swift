//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

@available(*, deprecated, message: "Please use `HttpApiClient`")
public struct JsonWebserviceFormat: WebserviceFormat {
	public static let httpHeaders = [
		"Accept": "application/json",
		"Content-Type": "application/json"
	]

	public init() {}

	public func serialize<T>(encodable: T) -> Result<Data, Error> where T: Encodable {
		Result { try JSONEncoder().encode(encodable) }
	}

	@available(iOS 10.0, *)
	public func serialize<T>(encodable: T, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .iso8601) -> Result<Data, Error> where T: Encodable {
		Result {
			let encoder = JSONEncoder()
			encoder.dateEncodingStrategy = dateEncodingStrategy
			return try encoder.encode(encodable)
		}
	}

	public func deserialize<T>(decodable: Data) -> Result<T, Error> where T: Decodable {
		Result { try JSONDecoder().decode(T.self, from: decodable) }
	}

	@available(iOS 10.0, *)
	public func deserialize<T>(decodable: Data, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) -> Result<T, Error> where T: Decodable {
		Result {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = dateDecodingStrategy
			return try decoder.decode(T.self, from: decodable)
		}
	}
}
