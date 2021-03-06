//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

/**
 Atomic type syncs all value mutations on a serial queue.
 Use this type when ever thread safety is a conern.
 */
public final class Atomic<T> {
	private let queue: DispatchQueue
	private var internalValue: T

	public init(_ value: T, queueIdentifier: String = "eu.topmind.kit.atomic") {
		queue = DispatchQueue(label: queueIdentifier)
		internalValue = value
	}

	public var value: T {
		queue.sync {
			self.internalValue
		}
	}

	@discardableResult
	public func mutate(_ transform: (inout T) -> Void) -> T {
		queue.sync {
			transform(&self.internalValue)
			return self.internalValue
		}
	}
}
