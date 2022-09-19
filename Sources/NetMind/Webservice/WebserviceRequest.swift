//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public enum HttpMethod: String {
	case post = "POST", get = "GET", delete = "DELETE", put = "PUT", patch = "PATCH"
}

public enum WebserviceRequestError: Error {
	case couldNotCreateUrl(URL)

	public var localizedDescription: String {
		switch self {
		case let .couldNotCreateUrl(url):
			return "Could not create URL for \(url)"
		}
	}
}

@available(*, deprecated, message: "Please use `HttpApiClient`")
public protocol WebserviceRequest {
	/// HTTP query parameters for the request
	var queryParameters: [String: String] { get }
	/// Additional sub path for the request
	var path: String { get }
	/// HTTP Method for the request
	var method: HttpMethod { get }
	/// Data encoding for the given request payload.
	func encode(with format: WebserviceFormat) -> Result<Data, Error>?
	/// Data decoding for the request's response, use this method to define custom date formatting.
	/// Default Implementation uses caller's formatter default.
	func decode<T: Decodable>(response: WebserviceResponse, with format: WebserviceFormat) -> Result<T, Error>
}

public extension WebserviceRequest {
	/// Default implementation, override if customizations are required (like date formatting)
	func decode<T: Decodable>(response: WebserviceResponse, with format: WebserviceFormat) -> Result<T, Error> {
		format.deserialize(decodable: response.data)
	}
}

extension WebserviceRequest {
	func url(for serviceUrl: URL) -> Result<URL, Error> {
		let url = serviceUrl.appendingPathComponent(path)
		guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			return .failure(WebserviceRequestError.couldNotCreateUrl(serviceUrl))
		}

		components.queryItems = queryParameters.map {
			URLQueryItem(name: $0.key, value: "\($0.value)")
		}

		guard let requestUrl = components.url else {
			return .failure(WebserviceRequestError.couldNotCreateUrl(serviceUrl))
		}

		return .success(requestUrl)
	}
}
