//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public enum RestResourceRequest<T: Codable, U: Equatable>: WebserviceRequest {

    case get(id: U)
    case create(T)
    case update(id: U, T)
    case delete(id: U)

    public var queryParameters: [String: String] {
        return [:]
    }

    public func encode(with format: WebserviceFormat) -> Result<Data, Error>? {
        switch self {
        case let .create(resource), let .update(_, resource):
            return format.serialize(encodable: resource)

        default: // get / delete
            return nil
        }
    }

    public func decode<T>(response: WebserviceResponse, with format: WebserviceFormat) -> Result<T, Error> where T: Decodable {
        return format.deserialize(decodable: response.data)
    }

    public var path: String {
        switch self {
        case let .get(id): return "\(id)"
        case let .delete(id): return "\(id)"
        case let .update(id, _): return "\(id)"
        default: return ""
        }
    }

    public var method: HttpMethod {
        switch self {
        case .get: return .get
        case .create: return .post
        case .update: return .put
        case .delete: return .delete
        }
    }
}
