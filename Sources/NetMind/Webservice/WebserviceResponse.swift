//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public struct WebserviceResponse {
    public let reqeustUrl: URL?
    public let statusCode: Int
    public let localizedStatusCodeString: String
    public let data: Data
    public let allHeaderFields: [AnyHashable: Any]

    public init(requestUrl: URL?, statusCode: Int, data: Data, allHeaderFields: [AnyHashable: Any]) {
        self.reqeustUrl = requestUrl
        self.statusCode = statusCode
        self.localizedStatusCodeString = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        self.data = data
        self.allHeaderFields = allHeaderFields
    }
}
