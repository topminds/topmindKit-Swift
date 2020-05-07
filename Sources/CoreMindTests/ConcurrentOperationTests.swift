//
//  ConcurrentOperationTests.swift
//  topmindKit
//
//  Created by Martin Gratzer on 17/03/2017.
//  Copyright © 2017 topmind mobile app solutions. All rights reserved.
//

import XCTest
@testable import CoreMind

final class ConcurrentOperationTests: XCTestCase {

    let queue = OperationQueue()

    func testProperties() {
        let sut = ConcurrentOperation()
        XCTAssertTrue(sut.isAsynchronous)
    }

    func testStart() {
        let sut = ConcurrentOperation()
        sut.start()

        XCTAssertEqual(.executing, sut.state)
    }

    func testCancel() {
        let sut = ConcurrentOperation()
        sut.start()
        sut.cancel()

        XCTAssertEqual(.finished, sut.state)
        XCTAssertEqual(.cancelled, (sut.error as? ConcurrentOperation.Error) )
    }

    func testIsReady() {
        let sut = ConcurrentOperation()

        XCTAssertTrue(sut.isReady)
        XCTAssertFalse(sut.isExecuting)
        XCTAssertFalse(sut.isFinished)
    }

    func testIsExecuting() {
        let sut = ConcurrentOperation()
        sut.start()

        XCTAssertFalse(sut.isReady)
        XCTAssertTrue(sut.isExecuting)
        XCTAssertFalse(sut.isFinished)
    }

    func testIsFinnished() {
        let sut = ConcurrentOperation()
        sut.start()
        sut.cancel()

        XCTAssertFalse(sut.isReady)
        XCTAssertFalse(sut.isExecuting)
        XCTAssertTrue(sut.isFinished)
    }

    func testIgnoreCancelWithoutStart() {
        let sut = ConcurrentOperation()
        sut.cancel()

        XCTAssertTrue(sut.isReady)
        XCTAssertFalse(sut.isExecuting)
        XCTAssertFalse(sut.isFinished)
    }

    func testRegularAsyncOperationRunning() {
        let sut = ConcurrentOperation()

        let e = expectation(description: "sut.completionBlock")
        sut.completionBlock = {
            e.fulfill()
        }

        queue.addOperations([sut], waitUntilFinished: false)

        // give the operation 1 sec to change its state
        Thread.sleep(until: Date().addingTimeInterval(1))

        XCTAssertFalse(sut.isReady)
        XCTAssertTrue(sut.isExecuting)
        XCTAssertFalse(sut.isFinished)

        sut.finish(error: nil)

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertFalse(sut.isReady)
        XCTAssertFalse(sut.isExecuting)
        XCTAssertTrue(sut.isFinished)
        XCTAssertNil(sut.error)

        XCTAssertEqual(0, queue.operationCount)
    }

    func testAsyncOperationRunningAndCancel() {
        let sut = ConcurrentOperation()

        let e = expectation(description: "sut.completionBlock")
        sut.completionBlock = {
            e.fulfill()
        }

        queue.addOperations([sut], waitUntilFinished: false)

        // give the operation 1 sec to change its state
        Thread.sleep(until: Date().addingTimeInterval(1))

        XCTAssertFalse(sut.isReady)
        XCTAssertTrue(sut.isExecuting)
        XCTAssertFalse(sut.isFinished)

        sut.cancel()

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertFalse(sut.isReady)
        XCTAssertFalse(sut.isExecuting)
        XCTAssertTrue(sut.isFinished)
        XCTAssertEqual(.cancelled, (sut.error as? ConcurrentOperation.Error) )

        XCTAssertEqual(0, queue.operationCount)
    }
}

