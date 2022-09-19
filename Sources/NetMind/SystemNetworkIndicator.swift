//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public typealias ActivityCount = Int

@available(*, deprecated)
public protocol NetworkActivityIndicator {
	@discardableResult
	static func startAnimating() -> ActivityCount
	@discardableResult
	static func stopAnimating() -> ActivityCount
	@discardableResult
	static func reset() -> ActivityCount
}

@available(*, deprecated)
public struct SystemNetworkIndicator: NetworkActivityIndicator {
	public private(set) static var activityCounter: ActivityCount = 0
	/// Set this callback
	/// e.g. iOS: SystemNetworkIndicator.showIndicatorCallback = { UIApplication.shared.isNetworkActivityIndicatorVisible = $0 }
	public static var showIndicatorCallback: ((Bool) -> Void)?

	@discardableResult
	public static func startAnimating() -> ActivityCount {
		incrementActivityCounter(by: 1)
	}

	@discardableResult
	public static func stopAnimating() -> ActivityCount {
		incrementActivityCounter(by: -1)
	}

	@discardableResult
	public static func reset() -> ActivityCount {
		incrementActivityCounter(by: -Int.max)
	}

	private static func incrementActivityCounter(by increment: ActivityCount) -> ActivityCount {
		objc_sync_enter(activityCounter)
		activityCounter = max(0, activityCounter + increment)
		showIndicatorCallback?(activityCounter > 0)
		objc_sync_exit(activityCounter)
		return activityCounter
	}
}
