//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Combine
import Foundation

final class JsonHttpApiClient: HttpApiClient {
	let session: URLSession
	weak var delegate: HttpApiClientDelegate?

	init() {
		session = URLSession(configuration: URLSessionConfiguration.ephemeral.withJsonAcceptHeaders().withJsonContentTypeHeaders())
	}

	init(configuration: URLSessionConfiguration, delegate: HttpApiClientDelegate? = nil) {
		session = URLSession(configuration: configuration)
		self.delegate = delegate
	}

	func get<T: Decodable>(url: URL, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil, delegate: URLSessionTaskDelegate? = nil, additionalHeaders: [String: String]? = nil) async throws -> T {
		try await result(for: .get(url), dateDecodingStrategy: dateDecodingStrategy, delegate: delegate, additionalHeaders: additionalHeaders)
	}

	func post<T: Encodable, U: Decodable>(url: URL, payload: T?, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil, delegate: URLSessionTaskDelegate? = nil, additionalHeaders: [String: String]? = nil) async throws -> U {
		let body: Data? = try payload.map { try JSONEncoder(dateEncodingStrategy: dateEncodingStrategy).encode($0) }
		return try await result(for: .post(url, body), dateDecodingStrategy: dateDecodingStrategy, delegate: delegate, additionalHeaders: additionalHeaders)
	}

	func put<T: Encodable, U: Decodable>(url: URL, payload: T?, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil, delegate: URLSessionTaskDelegate? = nil, additionalHeaders: [String: String]? = nil) async throws -> U {
		let body: Data? = try payload.map { try JSONEncoder(dateEncodingStrategy: dateEncodingStrategy).encode($0) }
		return try await result(for: .put(url, body), dateDecodingStrategy: dateDecodingStrategy, delegate: delegate, additionalHeaders: additionalHeaders)
	}

	func patch<T: Encodable, U: Decodable>(url: URL, payload: T?, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil, delegate: URLSessionTaskDelegate? = nil, additionalHeaders: [String: String]? = nil) async throws -> U {
		let body: Data? = try payload.map { try JSONEncoder(dateEncodingStrategy: dateEncodingStrategy).encode($0) }
		return try await result(for: .patch(url, body), dateDecodingStrategy: dateDecodingStrategy, delegate: delegate, additionalHeaders: additionalHeaders)
	}

	func delete<T: Decodable>(url: URL, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil, delegate: URLSessionTaskDelegate? = nil, additionalHeaders: [String: String]? = nil) async throws -> T {
		try await result(for: .delete(url), dateDecodingStrategy: dateDecodingStrategy, delegate: delegate, additionalHeaders: additionalHeaders)
	}

	internal func result<T: Decodable>(for call: HttpCall, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil, delegate: URLSessionTaskDelegate? = nil, additionalHeaders: [String: String]? = nil) async throws -> T {
		var request = call.request
		for (key, value) in additionalHeaders ?? [:] {
			request.setValue(value, forHTTPHeaderField: key)
		}
		return try await result(for: request, dateDecodingStrategy: dateDecodingStrategy, delegate: delegate)
	}

	internal func result<T: Decodable>(for request: URLRequest, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil, delegate: URLSessionTaskDelegate? = nil) async throws -> T {
		do {
			let data = try await data(for: request, delegate: delegate)
			return try JSONDecoder(dateDecodingStrategy: dateDecodingStrategy).decode(data)
		} catch let error as HttpApiError {
			if let error = self.delegate?.httpApiClient(self, didFail: request, with: error) {
				throw error
			} else {
				throw error
			}
		} catch {
			throw error
		}
	}
}

extension URLSessionConfiguration {
	@discardableResult
	func withJsonAcceptHeaders() -> URLSessionConfiguration {
		withCustomHeader(key: "Accept", value: "application/json")
	}

	@discardableResult
	func withJsonContentTypeHeaders() -> URLSessionConfiguration {
		withCustomHeader(key: "Content-Type", value: "application/json")
	}

	@discardableResult
	func withUserAgentHeader(value: String) -> URLSessionConfiguration {
		withCustomHeader(key: "User-Agent", value: value)
	}

	@discardableResult
	func withCustomHeader(key: String, value: String) -> URLSessionConfiguration {
		var headers = httpAdditionalHeaders ?? [:]

		if headers[key] != nil {
			debugPrint("Overriding HTTP Header `\(key)` with value `\(value)`.")
		}

		headers[key] = value
		httpAdditionalHeaders = headers
		return self
	}
}

private extension JSONDecoder {
	/// Creates a JSONDecoder and sets the `dateDecodingStrategy`
	/// - Parameter dateDecodingStrategy: The date decoding strategy to use
	convenience init(dateDecodingStrategy: DateDecodingStrategy?) {
		self.init()
		self.dateDecodingStrategy = dateDecodingStrategy ?? self.dateDecodingStrategy
	}

	/// Generic decode method that wraps any JSON decoding error into `HttpApiError.decodingError`
	/// - Returns: The decoded instance of `T
	func decode<T: Decodable>(_ data: Data) throws -> T {
		do {
			return try decode(T.self, from: data)
		} catch {
			throw HttpApiError.decodingError(error)
		}
	}
}

private extension JSONEncoder {
	/// Creates a JSONDecoder and sets the `dateEncodingStrategy`
	/// - Parameter dateEncodingStrategy: The date encoding strategy to use
	convenience init(dateEncodingStrategy: DateEncodingStrategy?) {
		self.init()
		self.dateEncodingStrategy = dateEncodingStrategy ?? self.dateEncodingStrategy
	}
}
