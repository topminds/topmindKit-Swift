//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public class RatingStore {

    public enum Key: String {
        case firstAppLaunch
        case appLaunches
        case lastPresentation
        case lastInteraction

        fileprivate var rawValuePrefixed: String {
            return "eu.topmindKit.AppMind.RatingStore.\(rawValue)"
        }

        fileprivate static let all: [Key] = [.firstAppLaunch, .appLaunches, .lastPresentation, .lastInteraction]
    }

    fileprivate let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    public func removeAll() {
        Key.all.forEach {
            userDefaults.removeObject(forKey: $0.rawValuePrefixed)
        }
    }
}

extension RatingStore {
    public subscript(_ key: Key) -> Any? {
        get { return userDefaults.object(forKey: key.rawValuePrefixed) }
        set {
            if newValue == nil {
                userDefaults.removeObject(forKey: key.rawValuePrefixed)
            } else {
                userDefaults.set(newValue, forKey: key.rawValuePrefixed)
            }
        }
    }
}
