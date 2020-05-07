//
//  File.swift
//  
//
//  Created by Martin Gratzer on 21.08.19.
//

import Foundation
import Combine

public enum HttpApiError: Error, LocalizedError {
    case encodingError(Error)
    case decodingError(Error)
    case urlError(URLError)
    case unknown(Error?)
    case apiError(code: Int, data: Data, reason: String)

    public var errorDescription: String? {
        switch self {
        case .unknown(let error): return error?.localizedDescription ?? "Unknown error"
        case .apiError(let code, _, let reason): return "\(code) \(reason)"
        case .encodingError(let error): return error.localizedDescription
        case .decodingError(let error): return error.localizedDescription
        case .urlError(let error): return error.localizedDescription
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
        case .get(let url):
            var request = URLRequest(url: url)
            request.httpMethod = method
            return request

        case .post(let url, let body):
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.httpBody = body
            return request
        }
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol HttpApiClientDelegate: class {
    func httpApiClient(_ client: HttpApiClient, willSend request: inout URLRequest)
//    func httpApiClient(_ client: HttpApiClient, shouldSend request: URLRequest) -> Bool
//    func httpApiClient(_ client: HttpApiClient, didCompleteRawTaskForRequest request: URLRequest,
//                       withData data: Data?, response: URLResponse?, error: Error?)
//    func httpApiClient(_ client: HttpApiClient, receivedError error: Error, for request: URLRequest,
//                       response: URLResponse?, retryHandler: @escaping (_ shouldRetry: Bool) -> Void)
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol HttpApiClient: class {
    var session: URLSession { get }
    var delegate: HttpApiClientDelegate? { get }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension HttpApiClient {
    internal func send(call: HttpCall) -> AnyPublisher<Data, HttpApiError> {
        return send(request: call.request)
    }

    internal func send(request: URLRequest) -> AnyPublisher<Data, HttpApiError> {
                
        var mutableRequest = request
        delegate?.httpApiClient(self, willSend: &mutableRequest)
                
        return session
            .dataTaskPublisher(for: request)
            .mapError { HttpApiError.urlError($0) }
            .tryMap { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw HttpApiError.unknown(nil)
                }

                guard 200..<300 ~= httpResponse.statusCode else {
                    throw HttpApiError.apiError(code: httpResponse.statusCode,
                                                data: data,
                                                reason: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                    )
                }
                
                return data
            }
            .mapError { ($0 as? HttpApiError) ?? HttpApiError.unknown($0) }
            .eraseToAnyPublisher()
    }
}
