//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

@available(*, deprecated, message: "Please use `HttpApiClient`")
public protocol WebserviceCallerDelegate: AnyObject {
	func webserviceCaller(_ caller: WebserviceCaller, didRequestHeaders for: WebserviceRequest, completion: @escaping ([String: String]?) -> Void)
}

public enum WebserviceCallerError: Error {
	case noData

	public var localizedDescription: String {
		switch self {
		case .noData: return "Webservice did not return data"
		}
	}
}

/**
 A webservice caller represents a web API server or endpint.
 It's injected into web services to ease switching between servers and endpoints.
 */
@available(*, deprecated, message: "Please use `HttpApiClient`")
public protocol WebserviceCaller: AnyObject {
	var baseUrl: URL { get }
	var session: URLSession { get }
	var format: WebserviceFormat { get }
	var delegate: WebserviceCallerDelegate? { get } // ensure weak ref
	/// Error handler for custom error user info.
	/// e.g. responses like { "error": { "message": "Username missing", "code": 123 } }
	func errorHandler(response: WebserviceResponse) -> Result<WebserviceResponse, Error>
}

// MARK: Tasks

public extension WebserviceCaller {
	@discardableResult
	func sendDataTask(request: URLRequest, completion: @escaping (Result<WebserviceResponse, Error>) -> Void) -> URLSessionTask {
		let task = createDataTask(request: request, completion: completion)
		task.resume()
		return task
	}

	func createDataTask(request: URLRequest, completion: @escaping (Result<WebserviceResponse, Error>) -> Void) -> URLSessionTask {
		//        print(">")
		//        print("\( (request.url?.absoluteString ?? ""))")
		//        print("\(request.allHTTPHeaderFields)")

		session.dataTask(with: request) {
			data, response, error in

			// HTTP Error
			if let error = error {
				completion(.failure(error))
				return
			}

			// empty result
			guard let data = data else {
				completion(.failure(WebserviceCallerError.noData))
				return
			}

			//            print("<")
			//            print("\(String(data: data, encoding: .utf8) ?? "")")

			let httpResponse = response as? HTTPURLResponse
			let webServiceResponse = WebserviceResponse(
				requestUrl: httpResponse?.url,
				statusCode: httpResponse?.statusCode ?? 500,
				data: data,
				allHeaderFields: httpResponse?.allHeaderFields ?? [:]
			)
			completion(.success(webServiceResponse))
		}
	}
}

// MARK: Requests

extension WebserviceCaller {
	internal func request(for request: WebserviceRequest, serviceUrl: URL, headers: [String: String], completion: @escaping (Result<URLRequest, Error>) -> Void) {
		if let delegate = delegate {
			delegate.webserviceCaller(self, didRequestHeaders: request) {
				[weak self] delegateHeaders in

				guard let self = self else { return }

				let url = try? request.url(for: serviceUrl).get()
				var requestHeaders = headers
				for (key, value) in delegateHeaders ?? [:] {
					if requestHeaders[key] == nil {
						requestHeaders[key] = value
					} else {
						debugPrint("Global \(key) value will be overwritten by request specific value for call to `\(String(describing: url))`.")
					}
				}

				completion(self.request(for: request, serviceUrl: serviceUrl, headers: requestHeaders))
			}
		} else {
			completion(self.request(for: request, serviceUrl: serviceUrl, headers: headers))
		}
	}

	private func request(for request: WebserviceRequest, serviceUrl: URL, headers: [String: String]) -> Result<URLRequest, Error> {
		switch request.method {
		case .post, .delete, .put, .patch:
			return createRequest(for: request, serviceUrl: serviceUrl, headers: headers)

		case .get:
			return getRequest(for: request, serviceUrl: serviceUrl, headers: headers)
		}
	}

	private func getRequest(for request: WebserviceRequest, serviceUrl: URL, headers: [String: String]) -> Result<URLRequest, Error> {
		request.url(for: serviceUrl).map {
			NSMutableURLRequest(url: $0, method: "GET", headers: headers) as URLRequest
		}
	}

	private func createRequest(for request: WebserviceRequest, serviceUrl: URL, headers: [String: String]) -> Result<URLRequest, Error> {
		request.url(for: serviceUrl).flatMap { url in
			if let payload = request.encode(with: format) {
				return payload.map {
					NSMutableURLRequest(url: url, method: request.method.rawValue, body: $0, headers: headers) as URLRequest
				}
			} else {
				return .success(
					NSMutableURLRequest(url: url, method: request.method.rawValue, body: nil, headers: headers) as URLRequest
				)
			}
		}
	}
}

extension NSMutableURLRequest {
	convenience init(url: URL, method: String, body: Data? = nil, headers: [String: String]) {
		self.init(url: url)
		httpMethod = method
		httpBody = body
		headers.forEach {
			addValue($0.value, forHTTPHeaderField: $0.key)
		}
	}
}
