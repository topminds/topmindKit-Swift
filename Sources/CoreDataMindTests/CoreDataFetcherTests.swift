//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import CoreData
@testable import CoreDataMind
import XCTest

class CoreDataFetcherTests: CoreDataTests {
	var sut: CoreDataFetcher<Kitten>!

	override func setUp() {
		super.setUp()
		sut = CoreDataFetcher<Kitten>(context: stack!.mainContext)
	}

	func testCreateEntity() throws {
		let result = sut.create { $0.name = "test" }
		switch result {
		case let .success(kitten):
			XCTAssertEqual(kitten.name, "test")
		case let .failure(error):
			XCTFail(error.localizedDescription)
		}

		XCTAssertNotNil(stack)
		try stack?.mainContext.save()
	}

	func testCreateBuilder() {
		let expect = expectation(description: "builder callback")
		let result = sut.create {
			$0.name = "Soft Kitty"
			expect.fulfill()
		}

		waitForExpectations(timeout: 5, handler: nil)

		let kitty = unwrapEntityResult(result)

		XCTAssertEqual(kitty!.name, "Soft Kitty")
	}

	func testFindById() {
		let result = sut.find(identifier: tom!.objectID)
		XCTAssertEqual(unwrapEntityResult(result), tom)
	}

	func testFindByAttribute() {
		let result = sut.first(attribute: "name", value: "Tom" as AnyObject)
		XCTAssertEqual(unwrapEntityResult(result), tom)
	}

	func testFindByKeypath() {
		let result = sut.first(keyPath: \.name, value: "Tom" as AnyObject)
		XCTAssertEqual(unwrapEntityResult(result), tom)
	}

	func testFindFirstByAttributeFinding() {
		let result = sut.firstOrCreate(attribute: "name", value: "Tom" as AnyObject)
		XCTAssertEqual(unwrapEntityResult(result), tom)
	}

	func testFindFirstByKeypathFinding() {
		let result = sut.firstOrCreate(keyPath: \.name, value: "Tom" as AnyObject)
		XCTAssertEqual(unwrapEntityResult(result), tom)
	}

	func testFindFirstByAttributeCreating() {
		let result = sut.firstOrCreate(attribute: "name", value: "Soft Kitty" as AnyObject) {
			$0.name = "Soft Kitty"
		}
		let kitty = unwrapEntityResult(result)

		XCTAssertEqual(kitty!.name, "Soft Kitty")
	}

	func testFindFirstByKeypathCreating() {
		let result = sut.firstOrCreate(keyPath: \.name, value: "Soft Kitty" as AnyObject) {
			$0.name = "Soft Kitty"
		}
		let kitty = unwrapEntityResult(result)

		XCTAssertEqual(kitty!.name, "Soft Kitty")
	}

	func testAll() {
		XCTAssertEqual(2, unwrapCollectionResult(sut.all()).count)
	}

	func testAllSortedBy() {
		let result = sut.all(sortedBy: [NSSortDescriptor(key: "name", ascending: false)])
		let kittenNames = unwrapCollectionResult(result).map(\.name)

		XCTAssertEqual(["Tom", "Jerry"], kittenNames)
	}

	func testAllByAttribute() {
		_ = sut.create { $0.name = "Tom" }
		let result = sut.all(attribute: "name", value: "Tom" as AnyObject)
		let kittenNames = unwrapCollectionResult(result).map(\.name)
		XCTAssertEqual(["Tom", "Tom"], kittenNames)
	}

	func testAllByKeypath() {
		_ = sut.create { $0.name = "Tom" }
		let result = sut.all(keyPath: \.name, value: "Tom" as AnyObject)
		let kittenNames = unwrapCollectionResult(result).map(\.name)
		XCTAssertEqual(["Tom", "Tom"], kittenNames)
	}

	func testFirstWithConfig() {
		let predicate = NSPredicate(format: "name = %@", "Tom")
		let config = RequestConfig(predicate: predicate)
		let result = sut.first(configuration: config)
		XCTAssertEqual(unwrapEntityResult(result), tom)
	}

	func testFirstWithConfigOrCreate() {
		let predicate = NSPredicate(format: "name = %@", "Tom")
		let config = RequestConfig(predicate: predicate)
		let result = sut.firstOrCreate(configuration: config) {
			$0.name = "Soft Kitty"
		}
		let kitty = unwrapEntityResult(result)

		XCTAssertEqual(kitty!.name, "Soft Kitty")
		XCTAssertFalse(kitty!.objectID.isTemporaryID)
	}

	// MARK: - Async

	func testDelete() throws {
		let kittyName = "butch"
		guard createKittenWithName(kittyName) != nil else {
			return XCTFail("Could not load mock data")
		}

		let predicate = NSPredicate(format: "name = %@", kittyName)
		let configuration = RequestConfig(predicate: predicate)

		try sut.delete(configuration: configuration)

		let result = sut.all(attribute: "name", value: kittyName as AnyObject)
		let kittenNames = unwrapCollectionResult(result).map(\.name)

		XCTAssertEqual(kittenNames.count, 0)
	}

	func testMultipleDelete() throws {
		guard createKittenWithName("soft_kitty") != nil, createKittenWithName("warm_kitty") != nil else {
			return XCTFail("Could not load mock data")
		}

		try sut.context.save()
		XCTAssertEqual(4, unwrapCollectionResult(sut.all()).count)

		let predicate = NSPredicate(format: "name = %@ OR name = %@", "soft_kitty", "warm_kitty")
		let configuration = RequestConfig(predicate: predicate, includesPropertyValues: false)
		try sut.delete(configuration: configuration)

		XCTAssertEqual(2, unwrapCollectionResult(sut.all()).count)
	}

	func testBatchDeleteAll() throws {
		let configuration = RequestConfig(predicate: nil)
		try sut.delete(configuration: configuration)

		XCTAssertEqual(0, unwrapCollectionResult(sut.all()).count)
	}

	func testBatchDelete() throws {
		let kittyName = "butch"
		guard createKittenWithName(kittyName) != nil else {
			return XCTFail("Could not load mock data")
		}

		let predicate = NSPredicate(format: "name = %@", kittyName)
		let configuration = RequestConfig(predicate: predicate)

		try sut.batchDelete(configuration: configuration)

		let result = sut.all(attribute: "name", value: kittyName as AnyObject)
		let kittenNames = unwrapCollectionResult(result).map(\.name)

		XCTAssertEqual(kittenNames.count, 0)
	}

	func testBatchMultipleDelete() throws {
		guard createKittenWithName("soft_kitty") != nil, createKittenWithName("warm_kitty") != nil else {
			return XCTFail("Could not load mock data")
		}

		try sut.context.save()
		XCTAssertEqual(4, unwrapCollectionResult(sut.all()).count)

		let predicate = NSPredicate(format: "name = %@ OR name = %@", "soft_kitty", "warm_kitty")
		let configuration = RequestConfig(predicate: predicate, includesPropertyValues: false)
		try sut.batchDelete(configuration: configuration)

		XCTAssertEqual(2, unwrapCollectionResult(sut.all()).count)
	}

	func testDeleteAll() throws {
		let configuration = RequestConfig(predicate: nil)
		try sut.batchDelete(configuration: configuration)

		XCTAssertEqual(0, unwrapCollectionResult(sut.all()).count)
	}

	func testAsyncFirstByAttribute() {
		let expect = expectation(description: "fetcher callback")
		sut.first(attribute: "name", value: "Tom" as AnyObject) {
			XCTAssertEqual(self.tom, self.unwrapEntityResult($0))
			expect.fulfill()
		}

		waitForExpectations(timeout: 5, handler: nil)
	}

	func testAsyncAll() {
		let expect = expectation(description: "fetcher callback")
		sut.all {
			XCTAssertEqual(2, self.unwrapCollectionResult($0).count)
			expect.fulfill()
		}

		waitForExpectations(timeout: 5, handler: nil)
	}

	func testAsyncAllSortedBy() {
		let expect = expectation(description: "fetcher callback")
		sut.all(sortedBy: [NSSortDescriptor(key: "name", ascending: false)]) {
			let kittenNames = self.unwrapCollectionResult($0).map(\.name)
			XCTAssertEqual(["Tom", "Jerry"], kittenNames)
			expect.fulfill()
		}

		waitForExpectations(timeout: 5, handler: nil)
	}

	func testAsyncAllByAttribute() {
		_ = sut.create { $0.name = "Tom" }

		let expect = expectation(description: "fetcher callback")
		sut.all(attribute: "name", value: "Tom" as AnyObject) {
			let kittenNames = self.unwrapCollectionResult($0).map(\.name)
			XCTAssertEqual(["Tom", "Tom"], kittenNames)
			expect.fulfill()
		}

		waitForExpectations(timeout: 5, handler: nil)
	}

	func testAsyncAllWithConfiguration() {
		_ = sut.create { $0.name = "Tom" }
		let predicate = NSPredicate(format: "name = %@", "Tom")
		let config = RequestConfig(predicate: predicate)
		let expect = expectation(description: "fetcher callback")
		sut.all(configuration: config) {
			let kittenNames = self.unwrapCollectionResult($0).map(\.name)
			XCTAssertEqual(["Tom", "Tom"], kittenNames)
			expect.fulfill()
		}

		waitForExpectations(timeout: 5, handler: nil)
	}

	// MARK: - Helper

	func unwrapCollectionResult(_ result: Result<[Kitten], Error>) -> [Kitten] {
		switch result {
		case let .success(kittens):
			return kittens

		case let .failure(error):
			XCTFail(error.localizedDescription)
			return []
		}
	}

	func unwrapEntityResult(_ result: Result<Kitten, Error>) -> Kitten? {
		switch result {
		case let .success(kitten):
			return kitten

		case let .failure(error):
			XCTFail(error.localizedDescription)
			return nil
		}
	}
}
