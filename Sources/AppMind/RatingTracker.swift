//
//  RatingTracker.swift
//  topmindKit
//
//  Created by Denis Andrašec on 20.03.17.
//  Copyright © 2017 topmind mobile app solutions. All rights reserved.
//

import Foundation

public class RatingTracker {

    private let timeSinceFirstAppLaunch: TimeInterval
    private let numberOfAppLaunches: UInt
    private let timeBetweenPresentations: TimeInterval
    private let timeBetweenInteractions: TimeInterval

    fileprivate let ratingStore: RatingStore

    public init(timeSinceFirstAppLaunch: TimeInterval,
         numberOfAppLaunches: UInt,
         timeBetweenPresentations: TimeInterval,
         timeBetweenInteractions: TimeInterval,
         ratingStore: RatingStore) {

        self.timeSinceFirstAppLaunch = abs(timeSinceFirstAppLaunch)
        self.numberOfAppLaunches = numberOfAppLaunches
        self.timeBetweenPresentations = abs(timeBetweenPresentations)
        self.timeBetweenInteractions = abs(timeBetweenInteractions)
        self.ratingStore = ratingStore
    }

    public func timeForRating() -> Bool {
        let now = Date().timeIntervalSince1970

        guard let firstAppLaunch = ratingStore[.firstAppLaunch] as? TimeInterval, abs(firstAppLaunch - now) >= timeSinceFirstAppLaunch else {
            return false
        }

        guard let appLaunches = ratingStore[.appLaunches] as? UInt, appLaunches >= numberOfAppLaunches else {
            return false
        }

        if let lastPresentation = ratingStore[.lastPresentation] as? TimeInterval, abs(lastPresentation - now) < timeBetweenPresentations {
            return false
        }

        if let lastInteraction = ratingStore[.lastInteraction] as? TimeInterval, abs(lastInteraction - now) < timeBetweenInteractions {
            return false
        }

        return true
    }
}

extension RatingTracker {

    fileprivate func trackFirstAppLaunch() {
        if ratingStore[.firstAppLaunch] == nil {
            ratingStore[.firstAppLaunch] = Date().timeIntervalSince1970
        }
    }

    public func trackAppLaunch() {
        let appLaunches = ratingStore[.appLaunches] as? UInt ?? 0
        ratingStore[.appLaunches] = appLaunches + 1
    }

    public func trackPresentation() {
        ratingStore[.lastPresentation] = Date().timeIntervalSince1970
    }

    public func trackInteraction() {
        ratingStore[.lastInteraction] = Date().timeIntervalSince1970
    }
}


