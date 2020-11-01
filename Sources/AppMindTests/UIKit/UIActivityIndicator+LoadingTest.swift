//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#if os(iOS)
	import AppMind
	import UIKit
	import XCTest

	final class UIActivityIndicatorLoadingTest: XCTestCase {
		let sut = UIActivityIndicatorView(frame: .zero)

		func testIsLoading() {
			// testing getter
			sut.startAnimating()
			XCTAssertEqual(sut.isAnimating, sut.isLoading)

			sut.stopAnimating()
			XCTAssertEqual(sut.isAnimating, sut.isLoading)

			// testing setting
			sut.isLoading = false
			XCTAssertEqual(sut.isAnimating, false)

			sut.isHidden = true
			sut.isLoading = true
			XCTAssertEqual(sut.isAnimating, true)
			XCTAssertEqual(sut.isHidden, false)
		}
	}
#endif
