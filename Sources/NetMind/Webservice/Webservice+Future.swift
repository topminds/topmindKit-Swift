//
//  Webservice+Future.swift
//  NetMind
//
//  Created by Martin Gratzer on 04.03.19.
//

import Foundation

#if canImport(CoreMind)
import CoreMind

extension Webserivce {

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
