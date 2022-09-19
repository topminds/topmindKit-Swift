//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Combine
import Foundation

public typealias HttpApiPublisher<T> = AnyPublisher<T, HttpApiError>

public enum HttpApiError: Error, LocalizedError {
	case encodingError(Error)
	case decodingError(Error)
	case urlError(URLError)
	case unknown(Error?)
	case apiError(code: Int, data: Data, reason: String, headers: [AnyHashable: Any]?)

	public var errorDescription: String? {
		switch self {
		case let .unknown(error):
			return error?.localizedDescription ?? "Unknown error"

		case let .apiError(code, _, reason, _):
			return "\(code) \(reason)"

		case let .encodingError(error):
			return error.localizedDescription

		case let .decodingError(error):
			return error.localizedDescription

		case let .urlError(error):
			return error.localizedDescription
		}
	}
}
