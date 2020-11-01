//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// swiftlint:disable variable_name

import CommonCrypto
import Foundation

public extension String {
	var md2: String? {
		hashData?.md2.hex
	}

	var md4: String? {
		hashData?.md4.hex
	}

	var md5: String? {
		hashData?.md5.hex
	}

	var sha1: String? {
		hashData?.sha1.hex
	}

	var sha224: String? {
		hashData?.sha224.hex
	}

	var sha256: String? {
		hashData?.sha256.hex
	}

	var sha384: String? {
		hashData?.sha384.hex
	}

	var sha512: String? {
		hashData?.sha512.hex
	}

	// MARK: - Private

	private var hashData: Data? {
		data(using: .utf8)
	}
}
