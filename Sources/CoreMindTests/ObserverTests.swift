//
//  ObserverTests.swift
//  topmindKit
//
//  Created by Martin Gratzer on 02/09/2016.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
//

import XCTest
@testable import CoreMind

protocol DummyObserverType: Observer {
    func dummyDidChange()
}

final class DummyObservable: Observable {
    typealias ObserverType = DummyObserverType
    var weakObservers = [WeakBox]()

    func magic() {
        observers.forEach {
            $0.dummyDidChange()
        }
    }
}

final class DummyObserver: DummyObserverType {
    private(set) var numberOfdidChangeCalls = 0
    func dummyDidChange() {
        numberOfdidChangeCalls += 1
    }
}

final class DummyObserver2: Observer {

}

final class ObserverTests: XCTestCase {

    var observer: DummyObserver?
    var sut: DummyObservable!

    override func setUp() {
        super.setUp()
        sut = DummyObservable()

    }

    func testObserverCalled() {
        givenObserving()

        whenChanging()
        whenChanging()

        XCTAssertEqual(observer?.numberOfdidChangeCalls, 2)
    }

    func testObserverShouldOnlyGetAddedOnce() {
        givenObserving()

        whenAddingObserverAgain()

        XCTAssertEqual(sut.observers.count, 1)
    }

    func testObserverRemoved() {
        givenObserving()

        whenRemovingObserver()

        XCTAssertTrue(sut.observers.isEmpty)
        XCTAssertTrue(sut.weakObservers.isEmpty)
    }

    func testCleanReleasedObserver() {
        givenObserving()

        whenObserverIsReleased()
        whenChanging()

        XCTAssertTrue(sut.observers.isEmpty)
    }

    func testShouldRemoveReleasedObserversOnAdd() {
        givenObserving() // +1

        whenAddingObserver() // +1
        whenAddingObserver() // +1

        let needToHoldRef = whenAddingObserver() // -1 +1

        XCTAssertEqual(sut.observers.count, 2)
        XCTAssertEqual(sut.weakObservers.count, 2)
        XCTAssertTrue(sut.observers.contains(where: {
            needToHoldRef === $0
        }))
        XCTAssertTrue(sut.observers.contains(where: {
            observer === $0
        }))
    }

    func testShouldRemoveReleasedObserversOnRemove() {
        givenObserving() // +1
        whenAddingObserver() // +1
        whenAddingObserver() // +1

        whenRemovingObserver()

        XCTAssertEqual(sut.observers.count, 0)
        XCTAssertEqual(sut.weakObservers.count, 0)
    }

    func testAddMultipleObservers() {
        let obs1 = givenObserving()
        let obs2 = givenObserving()

        whenChanging()

        XCTAssertEqual(obs1.numberOfdidChangeCalls, 1)
        XCTAssertEqual(obs2.numberOfdidChangeCalls, 1)
    }

    func testShouldNotAddIncorrectObserverType() {
        givenIncorrectObserverType()

        XCTAssertTrue(sut.observers.isEmpty)
        XCTAssertTrue(sut.weakObservers.isEmpty)
    }

    func testRemoveNonExistingObserverShouldBeIgnored() {
        givenObserving()

        let unknownObserver = DummyObserver()
        sut.remove(observer: unknownObserver)

        XCTAssertEqual(sut.observers.count, 1)
    }

    // MARK: Helper

    @discardableResult
    func givenObserving() -> DummyObserver {
        let observer = whenAddingObserver()
        self.observer = observer
        return observer
    }

    @discardableResult
    func givenIncorrectObserverType() -> DummyObserver2 {
        let observer = DummyObserver2()
        sut.add(observer: observer)
        return observer
    }

    func whenRemovingObserver() {
        guard let observer = observer else {
            XCTFail("`observer should not be null`")
            return
        }
        sut.remove(observer: observer)
    }

    func whenChanging() {
        sut.magic()
    }

    func whenObserverIsReleased() {
        observer = nil
    }

    @discardableResult
    func whenAddingObserver() -> DummyObserver {
        let observer = DummyObserver()
        sut.add(observer: observer)
        return observer
    }

    func whenAddingObserverAgain() {
        guard let observer = observer else {
            XCTFail("`observer should not be null`")
            return
        }
        sut.add(observer: observer)
    }
}
