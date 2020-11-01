//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

#if canImport(CoreMind)
	import CoreMind

	public extension Webservice {
		func send(method: Method, headers: [String: String]) -> Future<WebserviceResponse> {
			Future<WebserviceResponse> {
				promise in
				send(method: method, headers: headers) { promise($0) }
			}
		}

		func send<T: Decodable>(method: Method, headers: [String: String]) -> Future<T> {
			Future<T> {
				promise in
				send(method: method, headers: headers) { promise($0) }
			}
		}
	}
#endif
