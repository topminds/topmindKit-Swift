//
//  DistanceFormatterTests.swift
//  topmindKit
//
//  Created by Martin Gratzer on 23/10/2016.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
//

import XCTest
@testable import CoreMind

final class DistanceFormatterTests: XCTestCase {

    var sut: DistanceFormatter!
    var string: String?

    override func setUp() {
        super.setUp()
        sut = DistanceFormatter()
    }
    
    func testPrefixResetNegativeToPositive() {
        givenMetricFormatter()
        
        whenFormatting(meters: -999)
        whenFormatting(meters: 999)
        
        XCTAssertEqual("999m", string)
    }
    
    func testPrefixResetPositiveToNegative() {
        givenMetricFormatter()
        
        whenFormatting(meters: 999)
        whenFormatting(meters: -999)
        
        XCTAssertEqual("-999m", string)
    }
    
    // MARk: Positive

    func testMetricBelow1kmPositive() {
        givenMetricFormatter()

        whenFormatting(meters: 999)
        
        XCTAssertEqual("999m", string)
    }

    func testMetricBetween1kmAnd10kmPositive() {
        givenMetricFormatter()

        whenFormatting(meters: 5555.555)
        
        XCTAssertEqual("5,6km", string)
    }

    func testMetricBeyond10kmPositive() {
        givenMetricFormatter()

        whenFormatting(meters: 15555.555)
        
        XCTAssertEqual("16km", string)
    }

    func testImperialBelow1kmPositive() {
        givenImperialFormatter()

        whenFormatting(meters: 50)
        
        XCTAssertEqual("164ft", string)
    }

    func testImperialBetween1kmAnd10kmPositive() {
        givenImperialFormatter()

        whenFormatting(meters: 5555.555)
        
        XCTAssertEqual("3.5mi", string)
    }
    
    func testImperialBeyond10kmPositive() {
        givenImperialFormatter()
        
        whenFormatting(meters: 55555.555)
        
        XCTAssertEqual("35mi", string)
    }

    // MARk: Negative
    
    func testMetricBelow1kmNegative() {
        givenMetricFormatter()
        
        whenFormatting(meters: -999)
        
        XCTAssertEqual("-999m", string)
    }
    
    func testMetricBetween1kmAnd10kmNegative() {
        givenMetricFormatter()
        
        whenFormatting(meters: -5555.555)
        
        XCTAssertEqual("-5,6km", string)
    }
    
    func testMetricBeyond10kmNegative() {
        givenMetricFormatter()
        
        whenFormatting(meters: -15555.555)
        
        XCTAssertEqual("-16km", string)
    }
    
    func testImperialBelow1kmNegative() {
        givenImperialFormatter()
        
        whenFormatting(meters: -50)
        
        XCTAssertEqual("-164ft", string)
    }
    
    func testImperialBetween1kmAnd10kmNegative() {
        givenImperialFormatter()
        
        whenFormatting(meters: -5555.555)
        
        XCTAssertEqual("-3.5mi", string)
    }
    
    func testImperialBeyond10kmNegative() {
        givenImperialFormatter()
        
        whenFormatting(meters: -55555.555)
        
        XCTAssertEqual("-35mi", string)
    }
    
    func testFormatterMultiplierResetMetric() {
        givenMetricFormatter()
        
        whenFormatting(meters: 500)
        XCTAssertEqual("500m", string)
        
        whenFormatting(meters: 5555.555)
        XCTAssertEqual("5,6km", string)
        
        whenFormatting(meters: 500)
        XCTAssertEqual("500m", string)
        
        whenFormatting(meters: 15555.555)
        XCTAssertEqual("16km", string)
        
        whenFormatting(meters: 500)
        XCTAssertEqual("500m", string)
    }
    
    func testFormatterMultiplierResetImperial() {
        givenImperialFormatter()
        
        whenFormatting(meters: 50)
        XCTAssertEqual("164ft", string)
        
        whenFormatting(meters: 5555.555)
        XCTAssertEqual("3.5mi", string)
        
        whenFormatting(meters: 50)
        XCTAssertEqual("164ft", string)
        
        whenFormatting(meters: 55555.555)
        XCTAssertEqual("35mi", string)
        
        whenFormatting(meters: 50)
        XCTAssertEqual("164ft", string)
    }

    // Mark: Helper

    func givenMetricFormatter() {
        sut.locale = Locale(identifier: "de_AT")
    }

    func givenImperialFormatter() {
        sut.locale = Locale(identifier: "en_US")
    }

    func whenFormatting(meters: Double) {
        string = sut.string(from: NSNumber(value: meters))
    }
}
