//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public extension Bundle {
	var appName: String? {
		infoDictionary?["CFBundleName"] as? String
	}

	var identifier: String? {
		bundleIdentifier
	}

	var versionNumber: String? {
		infoDictionary?["CFBundleShortVersionString"] as? String
	}

	var buildNumber: String? {
		infoDictionary?["CFBundleVersion"] as? String
	}
}
