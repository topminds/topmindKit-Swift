//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public struct BundleInfo {
	public let name: String
	public let bundleIndentifier: String
	public let version: String
	public let build: String

	public init(bundle: Bundle) {
		bundleIndentifier = bundle.identifier ?? "eu.topmind.unknown"
		version = bundle.versionNumber ?? "0.0"
		build = bundle.buildNumber ?? "0"
		name = bundle.appName ?? "Unknown"
	}
}
