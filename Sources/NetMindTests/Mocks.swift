//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation
import NetMind

enum MockError: Error {
    case fixtureFailure
}

// Webservice caller (injectable for testing, once per endpoint/server)
// Its easy to switch servers/endpoints with this injection
final class MockWebserviceCaller: WebserviceCaller {

    weak var delegate: WebserviceCallerDelegate?
    var format: WebserviceFormat = JsonWebserviceFormat()
    var shouldResponseWith: (Int, [String: String]) = (200, ["status": "ok"])
    var shouldFail = false
    var shouldFailWithCustomError = false

    let baseUrl: URL = URL(string: "https://topmind.eu")!
    let session: URLSession = .shared

    func sendDataTask(request: URLRequest, completion: @escaping (Result<WebserviceResponse, Error>) -> Void) -> URLSessionTask {
        return createDataTask(request: request, completion: completion)
    }

    func createDataTask(request: URLRequest, completion: @escaping (Result<WebserviceResponse, Error>) -> Void) -> URLSessionTask {
        if shouldFail {
            completion(.failure(MockError.fixtureFailure))
        } else {
            let result = Result {
                WebserviceResponse(requestUrl: request.url,
                                   statusCode: shouldResponseWith.0,
                                   data: try JSONEncoder().encode(shouldResponseWith.1),
                                   allHeaderFields: [:])                
            }

            completion(result)
        }

        return URLSessionTask()
    }

    func errorHandler(response: WebserviceResponse) -> Result<WebserviceResponse, Error> {
        if shouldFailWithCustomError {
            return .failure(MockError.fixtureFailure)
        } else {
            return .success(response)
        }
    }
}

// Mock configuration for a REST Webservice
enum MockUserRequest: WebserviceRequest {

    case get(userId: String)
    case create(name: String)
    case update(userId: String, name: String)
    case delete(userId: String)

    var queryParameters: [String: String] {
        return [:]
    }

    func encode(with format: WebserviceFormat) -> Result<Data, Error>? {
        switch self {
        case let .create(user), //- post
        let .update(_, user): // put
            return format.serialize(encodable: user)

        default: // get / delete
            return nil
        }
    }

    var path: String {
        switch self {
        case let .get(userId),
             let .delete(userId),
             let .update(userId, _):
            return "\(userId)"

        default:
            return ""
        }
    }
    var method: HttpMethod {
        switch self {
        case .get: return .get
        case .create: return .post
        case .update: return .put
        case .delete: return .delete
        }
    }
}

final class MockUsersWebservice: Webservice {
    typealias Method = MockUserRequest
    let servicePath = "users"
    let caller: WebserviceCaller = MockWebserviceCaller() // usually injected
}
