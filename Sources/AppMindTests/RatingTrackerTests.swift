//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import AppMind
import XCTest

public extension TimeInterval {
	static let minute: TimeInterval = 60.0
	static let hour: TimeInterval = 60.0 * minute
	static let day: TimeInterval = hour * 24
	static let week: TimeInterval = day * 7
}

final class RatingTrackerTests: XCTestCase {
	var sut: RatingTracker!

	override func setUp() {
		super.setUp()
		RatingStore(userDefaults: UserDefaults.standard).removeAll()
	}

	func testFirstNotReachedStartupBecauseOfTime() {
		let store = storeWithOffsets(firstAppLaunch: (2 * .day - 1) * -1, appLaunches: 3)
		givenRatingTracker(store: store)
		XCTAssertFalse(sut.timeForRating())
	}

	func testFirstNotReachedStartupBecauseOfAppStarts() {
		let store = storeWithOffsets(firstAppLaunch: (2 * .day + 1) * -1, appLaunches: 2)
		givenRatingTracker(store: store)
		XCTAssertFalse(sut.timeForRating())
	}

	func testFirstReachedStartup() {
		let store = storeWithOffsets(firstAppLaunch: (2 * .day + 1) * -1, appLaunches: 3)
		givenRatingTracker(store: store)
		XCTAssertTrue(sut.timeForRating())
	}

	func testRecentPresentationNotReached() {
		let store = storeWithOffsets(lastPresentation: (.hour * 6 - 1) * -1)
		givenRatingTracker(store: store)
		XCTAssertFalse(sut.timeForRating())
	}

	func testRecentPresentationReached() {
		let store = storeWithOffsets(lastPresentation: (.hour * 6 + 1) * -1)
		givenRatingTracker(store: store)
		XCTAssertTrue(sut.timeForRating())
	}

	func testRecentInteractionNotReached() {
		let store = storeWithOffsets(lastInteraction: (.week * 50 - 1) * -1)
		givenRatingTracker(store: store)
		XCTAssertFalse(sut.timeForRating())
	}

	func testRecentInteractionReached() {
		let store = storeWithOffsets(lastInteraction: (.week * 50 + 1) * -1)
		givenRatingTracker(store: store)
		XCTAssertTrue(sut.timeForRating())
	}

	// MARK: Helper

	func givenRatingTracker(store: RatingStore = RatingStore(userDefaults: UserDefaults.standard)) {
		sut = RatingTracker(
			timeSinceFirstAppLaunch: .day * 2, // start showing it on 2nd day
			numberOfAppLaunches: 3,
			timeBetweenPresentations: .hour * 6, // show it 4 times a day until interaction
			timeBetweenInteractions: .week * 50, // don't ask again in the same season
			ratingStore: store
		)
	}

	func storeWithOffsets(firstAppLaunch: TimeInterval = .greatestFiniteMagnitude * -1,
	                      appLaunches: UInt = 9001,
	                      lastPresentation: TimeInterval = .greatestFiniteMagnitude * -1,
	                      lastInteraction: TimeInterval = .greatestFiniteMagnitude * -1) -> RatingStore {
		let now = Date()
		let store = RatingStore(userDefaults: UserDefaults.standard)

		store[.firstAppLaunch] = now.addingTimeInterval(firstAppLaunch).timeIntervalSince1970
		store[.appLaunches] = appLaunches
		store[.lastPresentation] = now.addingTimeInterval(lastPresentation).timeIntervalSince1970
		store[.lastInteraction] = now.addingTimeInterval(lastInteraction).timeIntervalSince1970

		return store
	}
}
