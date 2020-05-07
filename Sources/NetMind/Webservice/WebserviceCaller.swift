//
//  WebserviceCaller.swift
//  topmindKit
//
//  Created by Martin Gratzer on 18/03/2017.
//  Copyright © 2017 topmind development. All rights reserved.
//

import Foundation

public protocol WebserviceCallerDelegate: class {
    func webserviceCaller(_ caller: WebserviceCaller, didRequestHeaders for: WebserviceRequest, completion: @escaping ([String: String]?) -> ())
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
public protocol WebserviceCaller: class {
    var baseUrl: URL { get }
    var session: URLSession { get }
    var format: WebserviceFormat { get }
    var delegate: WebserviceCallerDelegate? { get } // ensure weak ref
    /// Error handler for custom error user info.
    /// e.g. responses like { "error": { "message": "Username missing", "code": 123 } }
    func errorHandler(response: WebserviceResponse) -> Result<WebserviceResponse, Error>
}

// MARK: Tasks

extension WebserviceCaller {

    @discardableResult
    public func sendDataTask(request: URLRequest, completion: @escaping (Result<WebserviceResponse, Error>) -> Void) -> URLSessionTask {
        let task = createDataTask(request: request, completion: completion)
        task.resume()
        return task
    }

    public func createDataTask(request: URLRequest, completion: @escaping (Result<WebserviceResponse, Error>) -> Void) -> URLSessionTask {

        //        print(">")
        //        print("\( (request.url?.absoluteString ?? ""))")
        //        print("\(request.allHTTPHeaderFields)")

        return session.dataTask(with: request) {
            (data, response, error) in

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

    internal func request(for request: WebserviceRequest, serviceUrl: URL, headers: [String: String], completion: @escaping (Result<URLRequest, Error>) -> ()) {

        if let delegate = self.delegate {

            delegate.webserviceCaller(self, didRequestHeaders: request) {
                [weak self] delegateHeaders in

                guard let self = self else { return }

                let url = try? request.url(for: serviceUrl).get()
                var requestHeaders = headers
                for (key, value) in (delegateHeaders ?? [:]) {
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
        return request.url(for: serviceUrl).map {
            NSMutableURLRequest(url: $0, method: "GET", headers: headers) as URLRequest
        }
    }

    private func createRequest(for request: WebserviceRequest, serviceUrl: URL, headers: [String: String]) -> Result<URLRequest, Error> {
        return request.url(for: serviceUrl).flatMap { url in

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
