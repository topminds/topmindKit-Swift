//
//  WebserviceFormat.swift
//  topmindKit
//
//  Created by Martin Gratzer on 18/03/2017.
//  Copyright © 2017 topmind development. All rights reserved.
//

import Foundation

public protocol WebserviceFormat {
    static var httpHeaders: [String: String] { get }

    func serialize<T: Encodable>(encodable: T) -> Result<Data, Error>

    @available(iOS 10.0, *)
    func serialize<T: Encodable>(encodable: T, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy) -> Result<Data, Error>

    func deserialize<T: Decodable>(decodable: Data) -> Result<T, Error>

    @available(iOS 10.0, *)
    func deserialize<T: Decodable>(decodable: Data, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) -> Result<T, Error>
}
