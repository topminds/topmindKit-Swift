//
//  Webservice.swift
//  topmindKit
//
//  Created by Martin Gratzer on 18/03/2017.
//  Copyright © 2017 topmind development. All rights reserved.
//

import Foundation

public protocol Webserivce {
    associatedtype Method: WebserviceRequest
    var servicePath: String { get }
    var caller: WebserviceCaller { get }
}

extension Webserivce {

    public func send<T: Decodable>(method: Method, headers: [String: String]?, completion: @escaping (Result<T, Error>) -> Void) {

        send(method: method, headers: headers) {
            (response: Result<WebserviceResponse, Error>) in

            let result: Result<T, Error> = response.flatMap {
                response in method.decode(response: response, with: self.caller.format)
            }

            completion(result)
        }
    }

    public func send(method: Method, headers: [String: String]?, completion: @escaping (Result<WebserviceResponse, Error>) -> Void) {

        let serviceUrl = caller.baseUrl.appendingPathComponent(servicePath)
        let errorHandler = caller.errorHandler

        caller.request(for: method, serviceUrl: serviceUrl, headers: headers ?? [:]) {
            [weak caller] in

            guard let caller = caller else { return }

            switch $0 {

            case .success(let request):
                caller.sendDataTask(request: request) {

                    let result = $0.flatMap(errorHandler)

                    #if DEBUG
                    if case .failure(let error) = result {
                        debugPrint("\(String(describing: request.httpMethod)) request to \(String(describing: request.url)) failed with \(error).")
                    }
                    #endif

                    completion(result)
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

}
