//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

@testable import CoreMind
import XCTest

final class DeviceInfoTests: XCTestCase {
	let sut = DeviceInfo()

	func testIdentiferNotChangingBetweenInstances() {
		let sut2 = DeviceInfo()
		XCTAssertEqual(sut.bundle.bundleIndentifier, sut2.bundle.bundleIndentifier)
	}

	func testModel() {
        #if arch(arm64)
		XCTAssertEqual(sut.model, "arm64")
        #else
        XCTAssertEqual(sut.model, "x86_64")
        #endif
	}

	func testOs() {
		var expected = ""
		#if os(iOS)
			let device = UIDevice.current
			expected = "\(device.systemName)/\(device.systemVersion)"
		#else
			let info = ProcessInfo.processInfo
			expected = info.operatingSystemVersionString
		#endif
		XCTAssertEqual(sut.operatingSystem, expected)
	}

	func testUserAgentString() {
		let info = BundleInfo(bundle: .main)
		let expected = "\(sut.appNameAndVersion(bundleInfo: info)) (\(sut.model) \(sut.operatingSystem) \(DeviceInfo.CFNetworkVersion()) \(DeviceInfo.darwinVersion()))"
		XCTAssertEqual(expected, sut.userAgentString())
	}
}
