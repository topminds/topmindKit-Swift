//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

@available(*, deprecated, message: "use Webservice")
public typealias Webserivce = Webservice

public protocol Webservice {
	associatedtype Method: WebserviceRequest
	var servicePath: String { get }
	var caller: WebserviceCaller { get }
}

public extension Webservice {
	func send<T: Decodable>(method: Method, headers: [String: String]?, completion: @escaping (Result<T, Error>) -> Void) {
		send(method: method, headers: headers) {
			(response: Result<WebserviceResponse, Error>) in

				let result: Result<T, Error> = response.flatMap {
					response in method.decode(response: response, with: self.caller.format)
				}

				completion(result)
		}
	}

	func send(method: Method, headers: [String: String]?, completion: @escaping (Result<WebserviceResponse, Error>) -> Void) {
		let serviceUrl = caller.baseUrl.appendingPathComponent(servicePath)
		let errorHandler = caller.errorHandler

		caller.request(for: method, serviceUrl: serviceUrl, headers: headers ?? [:]) {
			[weak caller] in

				guard let caller = caller else { return }

				switch $0 {
				case let .success(request):
					caller.sendDataTask(request: request) {
						let result = $0.flatMap(errorHandler)

						#if DEBUG
							if case let .failure(error) = result {
								debugPrint("\(String(describing: request.httpMethod)) request to \(String(describing: request.url)) failed with \(error).")
							}
						#endif

						completion(result)
					}

				case let .failure(error):
					completion(.failure(error))
				}
		}
	}
}
