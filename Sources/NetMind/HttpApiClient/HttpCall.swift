//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

enum HttpCall {
	case get(URL)
	case post(URL, Data?)
	case put(URL, Data?)
	case patch(URL, Data?)
	case delete(URL)
	/// add support for HEAD, CONNECT, OPTIONS, TRACE on demand

	var method: String {
		switch self {
		case .get: return "GET"
		case .post: return "POST"
		case .put: return "PUT"
		case .patch: return "PATCH"
		case .delete: return "DELETE"
		}
	}

	var request: URLRequest {
		switch self {
		case let .get(url), let .delete(url):
			return URLRequest(url: url, httpMethod: method)

		case let .post(url, body), let .put(url, body), let .patch(url, body):
			return URLRequest(url: url, httpMethod: method, httpBody: body)
		}
	}
}

private extension URLRequest {
	init(url: URL, httpMethod: String, httpBody: Data? = nil) {
		self.init(url: url)
		self.httpMethod = httpMethod
		self.httpBody = httpBody
	}
}
