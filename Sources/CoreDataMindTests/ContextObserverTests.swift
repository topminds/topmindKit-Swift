//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import CoreData
@testable import CoreDataMind
import XCTest

class ContextObserverTests: CoreDataTests {
	var tomPredicate = NSPredicate(format: "name = %@", "Tom")
	var jerryPredicate = NSPredicate(format: "name = %@", "Jerry")
	lazy var entity: NSEntityDescription = {
		NSEntityDescription.entity(forEntityName: "Kitten", in: self.stack!.mainContext)!
	}()

	// MARK: - TESTS

	func testInsertObservation() {
		let context = stack!.mainContext

		let expect = expectation(description: "observer fires")
		let observer = ContextObserver<Kitten>(context: context) { inserted, updated, deleted in
			XCTAssertTrue(inserted?.count == 2)
			XCTAssertNil(updated)
			XCTAssertNil(deleted)
			expect.fulfill()
		}

		XCTAssertNotNil(observer)

		_ = kittens.create { $0.name = "Tom 2" }
		_ = kittens.create { $0.name = "Jerry 2" }
		XCTAssertDoesNotThrow(stack!.save(context: context, completion: { _ in }))

		waitForExpectations(timeout: 3) { _ in }
	}

	func testdeleteObservation() {
		let expect = expectation(description: "observer fires")
		let observer = ContextObserver<Kitten>(context: stack!.mainContext) { inserted, updated, deleted in
			XCTAssertNil(inserted)
			XCTAssertNil(updated)
			XCTAssertTrue(deleted?.count == 2)
			expect.fulfill()
		}
		XCTAssertNotNil(observer)

		let context = stack!.mainContext
		context.delete(tom!)
		context.delete(jerry!)
		XCTAssertDoesNotThrow(stack!.save(context: context, completion: { _ in }))

		waitForExpectations(timeout: 3) { _ in }
	}

	func testUpdateObservation() {
		let expect = expectation(description: "observer fires")
		let observer = ContextObserver<Kitten>(context: stack!.mainContext) { inserted, updated, deleted in
			XCTAssertNil(inserted)
			XCTAssertTrue(updated?.count == 2)
			XCTAssertNil(deleted)
			expect.fulfill()
		}
		XCTAssertNotNil(observer)

		tom?.setValue("Tom edited", forKey: "name")
		jerry?.setValue("Jerry edited", forKey: "name")
		XCTAssertDoesNotThrow(stack!.save(context: stack!.mainContext, completion: { _ in }))

		waitForExpectations(timeout: 3) { _ in }
	}

	func testMixedObservations() {
		let expect = expectation(description: "observer fires")
		let observer = ContextObserver<Kitten>(context: stack!.mainContext) { inserted, updated, deleted in
			XCTAssertTrue(inserted?.count == 2)
			XCTAssertTrue(updated?.count == 1)
			XCTAssertTrue(deleted?.count == 1)
			expect.fulfill()
		}
		XCTAssertNotNil(observer)

		let context = stack!.mainContext

		_ = kittens.create { $0.name = "Tom 2" }
		_ = kittens.create { $0.name = "Jerry 2" }
		jerry?.setValue("Jerry edited", forKey: "name")
		context.delete(tom!)

		XCTAssertDoesNotThrow(stack!.save(context: context, completion: { _ in }))

		waitForExpectations(timeout: 3) { _ in }
	}

	func testInsertObservationWithPredicate() {
		let context = stack!.mainContext
		_ = kittens.create { $0.name = "Tom 2" }
		_ = kittens.create { $0.name = "Jerry 2" }

		let expect = expectation(description: "observer fires")
		let observer = ContextObserver<Kitten>(context: context, predicate: tomPredicate) { inserted, updated, deleted in
			XCTAssertNil(inserted)
			XCTAssertNil(updated)
			XCTAssertNil(deleted)
			expect.fulfill()
		}
		XCTAssertNotNil(observer)

		XCTAssertDoesNotThrow(stack!.save(context: context, completion: { _ in }))

		waitForExpectations(timeout: 3) { _ in }
	}

	func testdeleteObservationWithPredicate() {
		let expect = expectation(description: "observer fires")
		let observer = ContextObserver<Kitten>(context: stack!.mainContext, predicate: tomPredicate) { inserted, updated, deleted in
			XCTAssertNil(inserted)
			XCTAssertNil(updated)
			XCTAssertTrue(deleted?.count == 1)
			expect.fulfill()
		}
		XCTAssertNotNil(observer)

		let context = stack!.mainContext
		context.delete(tom!)
		context.delete(jerry!)
		XCTAssertDoesNotThrow(stack!.save(context: context, completion: { _ in }))

		waitForExpectations(timeout: 3) { _ in }
	}

	func testUpdateObservationWithPredicate() {
		let expect = expectation(description: "observer fires")
		let observer = ContextObserver<Kitten>(context: stack!.mainContext, predicate: tomPredicate) { inserted, updated, deleted in
			XCTAssertNil(inserted)
			XCTAssertTrue(updated?.count == 1)
			XCTAssertNil(deleted)
			expect.fulfill()
		}
		XCTAssertNotNil(observer)
		tom?.setValue("Tom", forKey: "name")
		jerry?.setValue("Jerry", forKey: "name")
		XCTAssertDoesNotThrow(stack!.save(context: stack!.mainContext, completion: { _ in }))

		waitForExpectations(timeout: 3) { _ in }
	}

	func testUpdateObservationWithPredicateAndNewValueForPredicateValue() {
		let expect = expectation(description: "observer fires")
		let observer = ContextObserver<Kitten>(context: stack!.mainContext, predicate: tomPredicate) { inserted, updated, deleted in
			XCTAssertNil(inserted)
			XCTAssertNil(updated)
			XCTAssertNil(deleted)
			expect.fulfill()
		}
		XCTAssertNotNil(observer)
		tom?.setValue("Tom edited", forKey: "name")
		jerry?.setValue("Jerry", forKey: "name")
		XCTAssertDoesNotThrow(stack!.save(context: stack!.mainContext, completion: { _ in }))

		waitForExpectations(timeout: 3) { _ in }
	}
}
