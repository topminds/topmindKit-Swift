//
//  RatingStoreTests.swift
//  topmindKit
//
//  Created by Denis Andrašec on 20.03.17.
//  Copyright © 2017 topmind mobile app solutions. All rights reserved.
//

import XCTest
import AppMind

final class RatingStoreTests: XCTestCase {

    var sut: RatingStore!
    
    override func setUp() {
        super.setUp()
        sut = RatingStore(userDefaults: UserDefaults(suiteName: nil)!)
        sut.removeAll()
    }
    
    override func tearDown() {
        sut.removeAll()
        super.tearDown()
    }
    
    func testFirstAppLaunch() {
        sut[.firstAppLaunch] = 1
        XCTAssertEqual(sut[.firstAppLaunch] as! Int, 1)
        sut = RatingStore(userDefaults: UserDefaults.standard)
        XCTAssertEqual(sut[.firstAppLaunch] as! Int, 1)
    }
    
    func testAppLaunches() {
        sut[.appLaunches] = 2
        XCTAssertEqual(sut[.appLaunches] as! Int, 2)
        sut = RatingStore(userDefaults: UserDefaults.standard)
        XCTAssertEqual(sut[.appLaunches] as! Int, 2)
    }
    
    func testLastPresentation() {
        sut[.lastPresentation] = 3
        XCTAssertEqual(sut[.lastPresentation] as! Int, 3)
        sut = RatingStore(userDefaults: UserDefaults.standard)
        XCTAssertEqual(sut[.lastPresentation] as! Int, 3)
    }
    
    func testLastInteraction() {
        sut[.lastInteraction] = 4
        XCTAssertEqual(sut[.lastInteraction] as! Int, 4)
        sut = RatingStore(userDefaults: UserDefaults.standard)
        XCTAssertEqual(sut[.lastInteraction] as! Int, 4)
    }
    
    func testRemoveAll() {
        sut[.firstAppLaunch] = 1
        sut[.appLaunches] = 2
        sut[.lastPresentation] = 3
        sut[.lastInteraction] = 4
        
        sut.removeAll()
        
        XCTAssertNil(sut[.firstAppLaunch])
        XCTAssertNil(sut[.appLaunches])
        XCTAssertNil(sut[.lastPresentation])
        XCTAssertNil(sut[.lastInteraction])
    }
}
