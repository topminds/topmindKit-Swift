//
//  RatingStore.swift
//  topmindKit
//
//  Created by Denis Andrašec on 17.03.17.
//  Copyright © 2017 topmind mobile app solutions. All rights reserved.
//

import Foundation

public class RatingStore {
    
    public enum Key: String {
        case firstAppLaunch = "firstAppLaunch"
        case appLaunches = "appLaunches"
        case lastPresentation = "lastPresentation"
        case lastInteraction = "lastInteraction"
        
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
