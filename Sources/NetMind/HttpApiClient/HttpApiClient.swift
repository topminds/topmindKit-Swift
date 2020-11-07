//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation
#if canImport(Combine)
	import Combine
#endif

public enum HttpApiError: Error, LocalizedError {
	case encodingError(Error)
	case decodingError(Error)
	case urlError(URLError)
	case unknown(Error?)
	case apiError(code: Int, data: Data, reason: String)

	public var errorDescription: String? {
		switch self {
		case let .unknown(error): return error?.localizedDescription ?? "Unknown error"
		case let .apiError(code, _, reason): return "\(code) \(reason)"
		case let .encodingError(error): return error.localizedDescription
		case let .decodingError(error): return error.localizedDescription
		case let .urlError(error): return error.localizedDescription
		}
	}
}

internal enum HttpCall {
	case get(URL)
	case post(URL, Data)

	var method: String {
		switch self {
		case .get: return "GET"
		case .post: return "POST"
		}
	}

	var request: URLRequest {
		switch self {
		case let .get(url):
			var request = URLRequest(url: url)
			request.httpMethod = method
			return request

		case let .post(url, body):
			var request = URLRequest(url: url)
			request.httpMethod = method
			request.httpBody = body
			return request
		}
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol HttpApiClientDelegate: AnyObject {
	func httpApiClient(_ client: HttpApiClient, willSend request: inout URLRequest)
	//    func httpApiClient(_ client: HttpApiClient, shouldSend request: URLRequest) -> Bool
	//    func httpApiClient(_ client: HttpApiClient, didCompleteRawTaskForRequest request: URLRequest,
	//                       withData data: Data?, response: URLResponse?, error: Error?)
	//    func httpApiClient(_ client: HttpApiClient, receivedError error: Error, for request: URLRequest,
	//                       response: URLResponse?, retryHandler: @escaping (_ shouldRetry: Bool) -> Void)
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol HttpApiClient: AnyObject {
	var session: URLSession { get }
	var delegate: HttpApiClientDelegate? { get }
}

#if canImport(Combine)
	@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
	extension HttpApiClient {
		func send(call: HttpCall) -> AnyPublisher<Data, HttpApiError> {
			send(request: call.request)
		}

		func send(request: URLRequest) -> AnyPublisher<Data, HttpApiError> {
			var mutableRequest = request
			delegate?.httpApiClient(self, willSend: &mutableRequest)

			return session
				.dataTaskPublisher(for: request)
				.mapError { HttpApiError.urlError($0) }
				.tryMap { data, response in
					guard let httpResponse = response as? HTTPURLResponse else {
						throw HttpApiError.unknown(nil)
					}

					guard 200 ..< 300 ~= httpResponse.statusCode else {
						throw HttpApiError.apiError(code: httpResponse.statusCode,
						                            data: data,
						                            reason: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
					}

					return data
				}
				.mapError { ($0 as? HttpApiError) ?? HttpApiError.unknown($0) }
				.eraseToAnyPublisher()
		}
	}
#endif
