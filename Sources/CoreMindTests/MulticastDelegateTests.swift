//
//  MulticastDelegateTests.swift
//  CoreMindTests
//
//  Created by Martin Gratzer on 10.05.18.
//  Copyright © 2018 topmind mobile app solutions. All rights reserved.
//

import XCTest
@testable import CoreMind

protocol MultiCastMockObserver: class {
    func dummyDidChange()
}

final class MultiCastMock {

    var observers = MulticastDelegate<MultiCastMockObserver>()

    func invokeObservers() {
        observers.invoke {
            $0.dummyDidChange()
        }
    }

    func add(observer: MultiCastMockObserver) {
        observers += observer
    }

    func remove(observer: MultiCastMockObserver) {
        observers -= observer
    }
}

final class MulticastObserverMock: MultiCastMockObserver {
    private(set) var numberOfdidChangeCalls = 0
    func dummyDidChange() {
        numberOfdidChangeCalls += 1
    }
}

final class MulticastDelegateTests: XCTestCase {

    var observer: MulticastObserverMock?
    var sut: MultiCastMock!

    override func setUp() {
        super.setUp()
        sut = MultiCastMock()

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
    }

    func testCleanReleasedObserver() {
        givenObserving()

        whenObserverIsReleased()
        whenChanging()

        XCTAssertTrue(sut.observers.isEmpty)
    }

    func testDontCleanReleasedObserver() {
        givenStrongObserving()

        whenObserverIsReleased()
        whenChanging()

        XCTAssertFalse(sut.observers.isEmpty)
    }

    func testShouldRemoveReleasedObserversOnAdd() {
        givenObserving() // +1

        whenAddingObserver() // +1
        whenAddingObserver() // +1

        let needToHoldRef = whenAddingObserver() // -1 +1

        XCTAssertEqual(sut.observers.count, 2)
        XCTAssertTrue(sut.observers.contains(needToHoldRef))
        XCTAssertTrue(sut.observers.contains(observer!))
    }

    func testShouldRemoveReleasedObserversOnRemove() {
        givenObserving() // +1
        whenAddingObserver() // +1
        whenAddingObserver() // +1

        whenRemovingObserver()

        XCTAssertEqual(sut.observers.count, 0)
    }

    func testAddMultipleObservers() {
        let obs1 = givenObserving()
        let obs2 = givenObserving()

        whenChanging()

        XCTAssertEqual(obs1.numberOfdidChangeCalls, 1)
        XCTAssertEqual(obs2.numberOfdidChangeCalls, 1)
    }

    func testRemoveNonExistingObserverShouldBeIgnored() {
        givenObserving()

        let unknownObserver = MulticastObserverMock()
        sut.remove(observer: unknownObserver)

        XCTAssertEqual(sut.observers.count, 1)
    }

    // Mark: Helper

    @discardableResult
    func givenObserving() -> MulticastObserverMock {
        let observer = whenAddingObserver()
        self.observer = observer
        return observer
    }

    @discardableResult
    func givenStrongObserving() -> MulticastObserverMock {
        sut.observers = MulticastDelegate<MultiCastMockObserver>(mode: .strong)
        let observer = whenAddingObserver()
        self.observer = observer
        return observer
    }

    func whenRemovingObserver() {
        guard let observer = observer else {
            XCTFail()
            return
        }
        sut.remove(observer: observer)
    }

    func whenChanging() {
        sut.invokeObservers()
    }

    func whenObserverIsReleased() {
        observer = nil
    }

    @discardableResult
    func whenAddingObserver() -> MulticastObserverMock {
        let observer = MulticastObserverMock()
        sut.add(observer: observer)
        return observer
    }

    func whenAddingObserverAgain() {
        guard let observer = observer else {
            XCTFail()
            return
        }
        sut.add(observer: observer)
    }

}
