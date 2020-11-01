//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import XCTest
import CoreData
@testable import CoreDataMind

class CoreDataFetcherTests: CoreDataTests {

    var sut: CoreDataFetcher<Kitten>!

    override func setUp() {
        super.setUp()
        sut = CoreDataFetcher<Kitten>(context: stack!.mainContext)
    }

    func testCreateEntity() {
        let result = sut.create { $0.name = "test" }
        switch result {
            case .success(let kitten):
                XCTAssertEqual(kitten.name, "test")

            case .failure(let error):
            XCTFail(error.localizedDescription)
        }

        guard let _ = try? stack!.mainContext.save() else {
            XCTFail()
            return
        }
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
        let kittenNames = unwrapCollectionResult(result).map { $0.name }

        XCTAssertEqual(["Tom", "Jerry"], kittenNames)
    }

    func testAllByAttribute() {
        _ = sut.create { $0.name = "Tom" }
        let result = sut.all(attribute: "name", value: "Tom" as AnyObject)
        let kittenNames = unwrapCollectionResult(result).map { $0.name }
        XCTAssertEqual(["Tom", "Tom"], kittenNames)
    }

    func testAllByKeypath() {
        _ = sut.create { $0.name = "Tom" }
        let result = sut.all(keyPath: \.name, value: "Tom" as AnyObject)
        let kittenNames = unwrapCollectionResult(result).map { $0.name }
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

    func testDelete() {
        let kittyName = "butch"
        guard let _ = createKittenWithName(kittyName) else {
            return XCTFail()
        }

        let predicate = NSPredicate(format: "name = %@", kittyName)
        let configuration = RequestConfig(predicate: predicate)

        do {
            try sut.delete(configuration: configuration)
        } catch {
            print("\(error)")
            XCTFail()
        }

        let result = sut.all(attribute: "name", value: kittyName as AnyObject)
        let kittenNames = unwrapCollectionResult(result).map { $0.name }

        XCTAssertEqual(kittenNames.count, 0)
    }

    func testMultipleDelete() {
        guard let _ = createKittenWithName("soft_kitty"), let _ = createKittenWithName("warm_kitty") else {
            return XCTFail()
        }

        do {
            try sut.context.save()
            XCTAssertEqual(4, self.unwrapCollectionResult(self.sut.all()).count)
        } catch {
            print("\(error)")
            XCTFail()
        }

        do {
            let predicate = NSPredicate(format: "name = %@ OR name = %@", "soft_kitty", "warm_kitty")
            let configuration = RequestConfig(predicate: predicate, includesPropertyValues: false)
            try sut.delete(configuration: configuration)
        } catch {
            print("\(error)")
            XCTFail()
        }

        XCTAssertEqual(2, self.unwrapCollectionResult(self.sut.all()).count)
    }

    func testBatchDeleteAll() {
        do {
            let configuration = RequestConfig(predicate: nil)
            try sut.delete(configuration: configuration)
        } catch {
            print("\(error)")
            XCTFail()
        }

        XCTAssertEqual(0, self.unwrapCollectionResult(self.sut.all()).count)
    }

    func testBatchDelete() {
        let kittyName = "butch"
        guard let _ = createKittenWithName(kittyName) else {
            return XCTFail()
        }

        let predicate = NSPredicate(format: "name = %@", kittyName)
        let configuration = RequestConfig(predicate: predicate)

        do {
            try sut.batchDelete(configuration: configuration)
        } catch {
            print("\(error)")
            XCTFail()
        }

        let result = sut.all(attribute: "name", value: kittyName as AnyObject)
        let kittenNames = unwrapCollectionResult(result).map { $0.name }

        XCTAssertEqual(kittenNames.count, 0)
    }

    func testBatchMultipleDelete() {
        guard let _ = createKittenWithName("soft_kitty"), let _ = createKittenWithName("warm_kitty") else {
            return XCTFail()
        }

        do {
            try sut.context.save()
            XCTAssertEqual(4, self.unwrapCollectionResult(self.sut.all()).count)
        } catch {
            print("\(error)")
            XCTFail()
        }

        do {
            let predicate = NSPredicate(format: "name = %@ OR name = %@", "soft_kitty", "warm_kitty")
            let configuration = RequestConfig(predicate: predicate, includesPropertyValues: false)
            try sut.batchDelete(configuration: configuration)
        } catch {
            print("\(error)")
            XCTFail()
        }

        XCTAssertEqual(2, self.unwrapCollectionResult(self.sut.all()).count)
    }

    func testDeleteAll() {
        do {
            let configuration = RequestConfig(predicate: nil)
            try sut.batchDelete(configuration: configuration)
        } catch {
            print("\(error)")
            XCTFail()
        }

        XCTAssertEqual(0, self.unwrapCollectionResult(self.sut.all()).count)
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
            let kittenNames = self.unwrapCollectionResult($0).map { $0.name }
            XCTAssertEqual(["Tom", "Jerry"], kittenNames)
            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testAsyncAllByAttribute() {
        _ = sut.create { $0.name = "Tom" }

        let expect = expectation(description: "fetcher callback")
        sut.all(attribute: "name", value: "Tom" as AnyObject) {
            let kittenNames = self.unwrapCollectionResult($0).map { $0.name }
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
            let kittenNames = self.unwrapCollectionResult($0).map { $0.name }
            XCTAssertEqual(["Tom", "Tom"], kittenNames)
            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    // MARK: - Helper

    func unwrapCollectionResult(_ result: Result<[Kitten], Error>) -> [Kitten] {
        switch result {
        case .success(let kittens):
            return kittens

        case .failure(let error):
            XCTFail(error.localizedDescription)
            return []
        }
    }

    func unwrapEntityResult(_ result: Result<Kitten, Error>) -> Kitten? {
        switch result {
        case .success(let kitten):
            return kitten

        case .failure(let error):
            XCTFail(error.localizedDescription)
            return nil
        }
    }

}
