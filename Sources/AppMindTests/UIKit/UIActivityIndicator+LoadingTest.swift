//
//  UIActivityIndicator+LoadingTest.swift
//  AppMind
//
//  Created by Raphael Seher on 07.01.19.
//  Copyright © 2019 topmind mobile app solutions. All rights reserved.
//

#if os(iOS)
import XCTest
import UIKit
import AppMind

final class UIActivityIndicatorLoadingTest: XCTestCase {
    
    let sut = UIActivityIndicatorView(frame: .zero)
    
    func testIsLoading() {
        // testing getter
        sut.startAnimating()
        XCTAssertEqual(sut.isAnimating, sut.isLoading)
        
        sut.stopAnimating()
        XCTAssertEqual(sut.isAnimating, sut.isLoading)
        
        // testing setting
        sut.isLoading = false
        XCTAssertEqual(sut.isAnimating, false)
        
        sut.isHidden = true
        sut.isLoading = true
        XCTAssertEqual(sut.isAnimating, true)
        XCTAssertEqual(sut.isHidden, false)
    }
    
}
#endif
