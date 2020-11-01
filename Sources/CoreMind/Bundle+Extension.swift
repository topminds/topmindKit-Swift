//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

extension Bundle {

    public var appName: String? {
        return infoDictionary?["CFBundleName"] as? String
    }

    public var identifier: String? {
        return bundleIdentifier
    }

    public var versionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    public var buildNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }

}
