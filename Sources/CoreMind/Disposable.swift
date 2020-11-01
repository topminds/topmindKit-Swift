//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

/**
 Disposable instnce holding a reference via "dispose: () -> ()".

 */
public final class Disposable {
	private let dispose: () -> Void

	init(_ dispose: @escaping () -> Void) {
		self.dispose = dispose
	}

	deinit {
		dispose()
	}
}
