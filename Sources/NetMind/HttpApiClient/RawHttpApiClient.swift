//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Combine
import Foundation

final class RawHttpApiClient: HttpApiClient {
	let session: URLSession
	weak var delegate: HttpApiClientDelegate?

	init() {
		session = URLSession(configuration: .ephemeral)
	}

	init(configuration: URLSessionConfiguration, delegate: HttpApiClientDelegate? = nil) {
		session = URLSession(configuration: configuration)
		self.delegate = delegate
	}

	func get(url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> Data {
		try await result(for: .get(url), delegate: delegate)
	}

	func post(url: URL, body: Data?, delegate: URLSessionTaskDelegate? = nil) async throws -> Data {
		try await result(for: .post(url, body), delegate: delegate)
	}

	func put(url: URL, body: Data?, delegate: URLSessionTaskDelegate? = nil) async throws -> Data {
		try await result(for: .put(url, body), delegate: delegate)
	}

	func patch(url: URL, body: Data?, delegate: URLSessionTaskDelegate? = nil) async throws -> Data {
		try await result(for: .patch(url, body), delegate: delegate)
	}

	func delete(url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> Data {
		try await result(for: .delete(url), delegate: delegate)
	}

	private func result(for call: HttpCall, delegate: URLSessionTaskDelegate?) async throws -> Data {
		let request = call.request
		do {
			return try await data(for: request, delegate: delegate)
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
