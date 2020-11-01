//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class JsonHttpApiClient: HttpApiClient {

    public let session: URLSession
    public weak var delegate: HttpApiClientDelegate?

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    public init() {
        session = URLSession(configuration: URLSessionConfiguration.ephemeral.withJsonAcceptAndContentTypeHeaders())
    }

    public init(configuration: URLSessionConfiguration) {
        session = URLSession(configuration: configuration.withJsonAcceptAndContentTypeHeaders())
    }

    public func get<T: Decodable>(url: URL) -> AnyPublisher<T, HttpApiError> {
        send(call: .get(url))
            .tryMap { try self.decoder.decode($0) }
            .mapError { ($0 as? HttpApiError) ?? HttpApiError.unknown($0) }
            .eraseToAnyPublisher()
    }

    public func post<T: Encodable, U: Decodable>(url: URL, payload: T) -> AnyPublisher<U, HttpApiError> {
        encoder
            .encode(payload)
            .map { self.send(call: .post(url, $0)) }
            .switchToLatest()
            .tryMap { try self.decoder.decode($0) }
            .mapError { ($0 as? HttpApiError) ?? HttpApiError.unknown($0) }
            .eraseToAnyPublisher()
    }
}

private extension URLSessionConfiguration {
    func withJsonAcceptAndContentTypeHeaders() -> URLSessionConfiguration {
        var headers = httpAdditionalHeaders ?? [:]
        headers["Accept"] = "application/json"
        headers["Content-Type"] = "application/json"
        httpAdditionalHeaders = headers
        return self
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private extension JSONEncoder {
    func encode<T: Encodable>(_ value: T) -> Future<Data, HttpApiError> {
        Future<Data, HttpApiError> {
            do {
                $0(.success(try self.encode(value)))
            } catch {
                $0(.failure(HttpApiError.encodingError(error)))
            }
        }
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private extension JSONDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try decode(T.self, from: data)
        } catch {
            throw HttpApiError.decodingError(error)
        }
    }
}
