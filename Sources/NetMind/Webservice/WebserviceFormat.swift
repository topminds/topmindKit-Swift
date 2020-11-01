//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
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
