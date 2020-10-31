//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

#if canImport(CoreMind)
import CoreMind

extension Webservice {

    public func send(method: Method, headers: [String: String]) -> Future<WebserviceResponse> {
        return Future<WebserviceResponse> {
            promise in
            send(method: method, headers: headers) { promise($0) }
        }
    }

    public func send<T: Decodable>(method: Method, headers: [String: String]) -> Future<T> {
        return Future<T> {
            promise in
            send(method: method, headers: headers) { promise($0) }
        }
    }
}
#endif
