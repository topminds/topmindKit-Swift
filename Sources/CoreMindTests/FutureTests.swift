//
//  FutureTests.swift
//  topmindKit
//
//  Created by Martin Gratzer on 27/03/2017.
//  Copyright © 2017 topmind mobile app solutions. All rights reserved.
//

import XCTest
@testable import CoreMind

final class FutureTests: XCTestCase {

    func testShouldComputeValue() {
        let sut = givenSuccessfullPromise(value: "fixture 1")

        let e = expectation(description: "\(#function)")
        sut.onResult {
            switch $0 {
            case .success(let value): XCTAssertEqual("fixture 1", value)
            case .failure: XCTFail()
            }

            e.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testShouldUseCachedValue() {
        let sut = givenSuccessfullPromise(value: "fixture 1")

        let e = expectation(description: "\(#function)")
        sut.onResult {
            switch $0 {
            case .success(let value): XCTAssertEqual("fixture 1", value)
            case .failure: XCTFail()
            }

            e.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        sut.onResult {
            switch $0 {
            case .success(let value): XCTAssertEqual("fixture 1", value)
            case .failure: XCTFail()
            }
        }
    }

    func testShouldComputeValueChained() {
        let sut = givenSuccessfullPromise(value: "fixture 1")

        let e = expectation(description: "\(#function)")
        sut
            .then {
                value -> Future<String> in
                XCTAssertEqual("fixture 1", value)
                return self.givenSuccessfullPromise(value: "fixture 2")
            }
            .then {
                value -> Future<String> in
                XCTAssertEqual("fixture 2", value)
                return self.givenSuccessfullPromise(value: "fixture 3")
            }
            .onResult {
                switch $0 {
                case .success(let value): XCTAssertEqual("fixture 3", value)
                case .failure: XCTFail()
                }

                e.fulfill()
            }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testShouldFail() {
        let sut = givenFailingfullPromise(value: "fixture 1")

        let e = expectation(description: "\(#function)")
        sut.onResult {
            switch $0 {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual("failed fixture 1", error as? String)
            }

            e.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testShouldFailChanedFirst() {
        let sut = givenFailingfullPromise(value: "fixture 1")

        let e = expectation(description: "\(#function)")
        sut
            .then {
                value -> Future<String> in
                XCTAssertEqual("fixture 1", value)
                return self.givenSuccessfullPromise(value: "fixture 2")
            }
            .then {
                value -> Future<String> in
                XCTAssertEqual("fixture 2", value)
                return self.givenSuccessfullPromise(value: "fixture 3")
            }
            .onResult {
                switch $0 {
                case .success: XCTFail()
                case .failure(let error): XCTAssertEqual("failed fixture 1", error as? String)
                }

                e.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testShouldFailChanedInBetween() {
        let sut = givenSuccessfullPromise(value: "fixture 1")

        let e = expectation(description: "\(#function)")
        sut
            .then {
                value -> Future<String> in
                XCTAssertEqual("fixture 1", value)
                return self.givenFailingfullPromise(value: "fixture 2")
            }
            .then {
                value -> Future<String> in
                XCTAssertEqual("fixture 2", value)
                return self.givenSuccessfullPromise(value: "fixture 3")
            }
            .onResult {
                switch $0 {
                case .success: XCTFail()
                case .failure(let error): XCTAssertEqual("failed fixture 2", error as? String)
                }

                e.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testShouldFailChanedLast() {
        let sut = givenSuccessfullPromise(value: "fixture 1")

        let e = expectation(description: "\(#function)")
        sut
            .then {
                value -> Future<String> in
                XCTAssertEqual("fixture 1", value)
                return self.givenSuccessfullPromise(value: "fixture 2")
            }
            .then {
                value -> Future<String> in
                XCTAssertEqual("fixture 2", value)
                return self.givenFailingfullPromise(value: "fixture 3")
            }
            .onResult {
                switch $0 {
                case .success: XCTFail()
                case .failure(let error): XCTAssertEqual("failed fixture 3", error as? String)
                }

                e.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    // MARK: Concurrency

    func testShouldReturnOnMainQueue() {
        let sut = givenSuccessfullPromise(resultQueue: .main, value: "fixture 1")

        let e = expectation(description: "\(#function)")
        sut.onResult { _ in
            XCTAssertTrue(Thread.isMainThread)
            e.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testShouldFailOnMainQueue() {
        let sut = givenFailingfullPromise(resultQueue: .main, value: "fixture 1")

        let e = expectation(description: "\(#function)")
        sut.onResult { _ in
            XCTAssertTrue(Thread.isMainThread)
            e.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testShouldReturnOnSpecificQueue() {
        let queue = DispatchQueue(label: "eu.topmind.kit.test")
        let sut = givenSuccessfullPromise(resultQueue: .specific(queue), value: "fixture 1")

        let e = expectation(description: "\(#function)")
        sut.onResult { _ in
            XCTAssertTrue(isOnQueueNamed("eu.topmind.kit.test"))
            e.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testShouldFailOnSpecificQueue() {
        let queue = DispatchQueue(label: "eu.topmind.kit.test")
        let sut = givenFailingfullPromise(resultQueue: .specific(queue), value: "fixture 1")

        let e = expectation(description: "\(#function)")
        sut.onResult { _ in
            XCTAssertTrue(isOnQueueNamed("eu.topmind.kit.test"))
            e.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testShouldReturnOnExecutionQueue() {
        let sut = givenSuccessfullPromise(resultQueue: .any, value: "fixture 1")

        let e = expectation(description: "\(#function)")
        sut.onResult { _ in
            XCTAssertTrue(isOnQueueNamed("eu.topmind.kit.test.concurrent"))
            e.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testShouldFailOnExecutionQueue() {
        let sut = givenFailingfullPromise(resultQueue: .any, value: "fixture 1")

        let e = expectation(description: "\(#function)")
        sut.onResult { _ in
            XCTAssertTrue(isOnQueueNamed("eu.topmind.kit.test.concurrent"))
            e.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    // Helper

    func givenSuccessfullPromise(resultQueue: ResultQueue = .any, value: String) -> Future<String> {
        return Future(resultQueue: resultQueue) {
            computed in

            givenConcurrentQueue().async {
                sleep(1)
                computed(.success(value))
            }
        }
    }

    func givenFailingfullPromise(resultQueue: ResultQueue = .any, value: String) -> Future<String> {
        return Future(resultQueue: resultQueue) {
            computed in

            givenConcurrentQueue().async {
                sleep(1)
                computed(.failure("failed \(value)"))
            }
        }
    }

    func givenConcurrentQueue() -> DispatchQueue {
        return DispatchQueue(label: "eu.topmind.kit.test.concurrent", attributes: .concurrent)
    }
}

func isOnQueueNamed(_ label: String) -> Bool {
    let cName = __dispatch_queue_get_label(nil)
    let name = String(cString: cName, encoding: .utf8)
    return name == label
}
