//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public typealias ActivityCount = Int

public protocol NetworkActivityIndicator {
    @discardableResult
    static func startAnimating() -> ActivityCount
    @discardableResult
    static func stopAnimating() -> ActivityCount
    @discardableResult
    static func reset() -> ActivityCount
}

public struct SystemNetworkIndicator: NetworkActivityIndicator {

    private(set) public static var activityCounter: ActivityCount = 0
    /// Set this callback
    /// e.g. iOS: SystemNetworkIndicator.showIndicatorCallback = { UIApplication.shared.isNetworkActivityIndicatorVisible = $0 }
    public static var showIndicatorCallback: ((Bool) -> ())?

    @discardableResult
    public static func startAnimating() -> ActivityCount {
        return incrementActivityCounter(by: 1)
    }

    @discardableResult
    public static func stopAnimating() -> ActivityCount {
        return incrementActivityCounter(by: -1)
    }

    @discardableResult
    public static func reset() -> ActivityCount {
        return incrementActivityCounter(by: -Int.max)
    }

    private static func incrementActivityCounter(by increment: ActivityCount) -> ActivityCount {
        objc_sync_enter(activityCounter)
        activityCounter = max(0, activityCounter + increment)
        showIndicatorCallback?(activityCounter > 0)
        objc_sync_exit(activityCounter)
        return activityCounter
    }
}
