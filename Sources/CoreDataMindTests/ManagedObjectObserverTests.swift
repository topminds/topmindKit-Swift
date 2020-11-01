//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import CoreData
@testable import CoreDataMind
import XCTest

final class ManagedObjectObserverTests: CoreDataTests {
	private var coreDataFetcher: CoreDataFetcher<Kitten>!
	private var sut: ManagedObjectObserver!

	override func setUp() {
		super.setUp()
		coreDataFetcher = CoreDataFetcher<Kitten>(context: stack!.mainContext)
	}

	func testCallbackOnUpdate() throws {
		let objectA = try givenInsertedObject(name: "a")

		let expect = expectation(description: "callback update")
		sut = ManagedObjectObserver(object: objectA) { changeType in
			XCTAssertEqual(changeType, ManagedObjectObserver.ChangeType.update)
			expect.fulfill()
		}

		whenObjectIsUpdated(object: objectA)
		waitForExpectations(timeout: 1, handler: nil)
	}

	func testCallbackOnRefresh() throws {
		let objectA = try givenInsertedObject(name: "a")

		let expect = expectation(description: "callback update")
		sut = ManagedObjectObserver(object: objectA) { changeType in
			XCTAssertEqual(changeType, ManagedObjectObserver.ChangeType.update)
			expect.fulfill()
		}

		whenObjectIsRefreshed(object: objectA)
		waitForExpectations(timeout: 1, handler: nil)
	}

	func testCallbackOnDeletion() throws {
		let objectA = try givenInsertedObject(name: "a")

		let expect = expectation(description: "callback delete")
		sut = ManagedObjectObserver(object: objectA) { changeType in
			XCTAssertEqual(changeType, ManagedObjectObserver.ChangeType.delete)
			expect.fulfill()
		}

		whenObjectIsDeleted(object: objectA)
		waitForExpectations(timeout: 1, handler: nil)
	}

	func testCallbackOnInvalidation() throws {
		let objectA = try givenInsertedObject(name: "a")

		let expect = expectation(description: "callback delete")
		sut = ManagedObjectObserver(object: objectA) { changeType in
			XCTAssertEqual(changeType, ManagedObjectObserver.ChangeType.delete)
			expect.fulfill()
		}

		whenObjectIsInvalidated(object: objectA)
		waitForExpectations(timeout: 1, handler: nil)
	}

	func testEnable() throws {
		let objectA = try givenInsertedObject(name: "a")

		let expect = expectation(description: "callback update")

		sut = ManagedObjectObserver(object: objectA, autoEnabled: false) { _ in
			XCTAssertEqual("update 2", objectA.name)
			expect.fulfill()
		}

		whenObjectIsUpdated(object: objectA, name: "update 1")
		sut.enable()
		whenObjectIsUpdated(object: objectA, name: "update 2")

		waitForExpectations(timeout: 1, handler: nil)
	}

	func testDisable() throws {
		let objectA = try givenInsertedObject(name: "a")

		let expect = expectation(description: "callback update")

		sut = ManagedObjectObserver(object: objectA, autoEnabled: false) { _ in
			XCTAssertEqual("update 1", objectA.name)
			expect.fulfill()
		}

		sut.enable()
		whenObjectIsUpdated(object: objectA, name: "update 1")
		sut.disable()
		whenObjectIsUpdated(object: objectA, name: "update 2")

		waitForExpectations(timeout: 1, handler: nil)
	}

	func testDisableAndEnable() throws {
		let objectA = try givenInsertedObject(name: "a")

		let expect = expectation(description: "callback update")

		sut = ManagedObjectObserver(object: objectA, autoEnabled: false) { _ in
			XCTAssertEqual("update", objectA.name)
			expect.fulfill()
		}

		sut.enable()
		sut.disable()
		sut.enable()
		whenObjectIsUpdated(object: objectA, name: "update")

		waitForExpectations(timeout: 1, handler: nil)
	}

	// MARK: Private

	private func givenInsertedObject(name: String) throws -> Kitten {
		let object = try coreDataFetcher.create { $0.name = name }.get()
		(try? object.managedObjectContext?.save()) as ()??
		return object
	}

	private func whenObjectIsUpdated(object: Kitten, name: String = "update") {
		do {
			object.name = name
			try object.managedObjectContext?.save()
		} catch {
			XCTFail("Could not save mock data")
		}
	}

	private func whenObjectIsRefreshed(object: Kitten) {
		object.managedObjectContext?.refresh(object, mergeChanges: false)
	}

	private func whenObjectIsDeleted(object: Kitten) {
		object.managedObjectContext?.delete(object)
	}

	private func whenObjectIsInvalidated(object: Kitten) {
		object.managedObjectContext?.reset()
	}
}
