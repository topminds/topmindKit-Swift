//
//  File.swift
//  
//
//  Created by Martin Gratzer on 22.08.19.
//

import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class RawHttpApiClient: HttpApiClient {

    public let session: URLSession
    public weak var delegate: HttpApiClientDelegate?

    public init() {
        session = URLSession(configuration: .ephemeral)
    }

    public init(configuration: URLSessionConfiguration) {
        session = URLSession(configuration: configuration)
    }
    
    public func get(url: URL) -> AnyPublisher<Data, HttpApiError> {
        send(call: .get(url))
    }

    public func post(url: URL, data: Data) -> AnyPublisher<Data, HttpApiError> {
        send(call: .post(url, data))
    }
}
