//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Combine
import Foundation

protocol HttpApiClientDelegate: AnyObject {
	func httpApiClient(_ client: HttpApiClient, willSend request: URLRequest) async throws -> URLRequest
	func httpApiClient(_ client: HttpApiClient, didFail request: URLRequest, with error: HttpApiError) -> Error
}

protocol HttpApiClient: AnyObject {
	var delegate: HttpApiClientDelegate? { get }
	var session: URLSession { get }
}

extension HttpApiClient {
	func data(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> Data {
		if #available(iOS 15.0, *) {
			return try Self.handleUrlSessionResult(
				try await session.data(
					for: await self.delegate?.httpApiClient(self, willSend: request) ?? request,
					delegate: delegate
				)
			)
		} else {
			return try Self.handleUrlSessionResult(
				try await session.data(
					for: await self.delegate?.httpApiClient(self, willSend: request) ?? request
				)
			)
		}
	}
}

private extension HttpApiClient {
	static func handleUrlSessionResult(_ result: (data: Data, response: URLResponse)) throws -> Data {
		guard let httpResponse = result.response as? HTTPURLResponse else {
			throw HttpApiError.unknown(nil)
		}

		guard 200 ..< 300 ~= httpResponse.statusCode else {
			throw HttpApiError.apiError(
				code: httpResponse.statusCode,
				data: result.data,
				reason: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode),
				headers: httpResponse.allHeaderFields
			)
		}

		return result.data
	}
}
