//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import XCTest
import CoreData
@testable import CoreDataMind

class CoreDataStackTests: XCTestCase {

    var stack: CoreDataStack?
    lazy var modelUrl: URL? = {
        return Bundle(for: CoreDataTests.self).url(forResource: "Model", withExtension: "momd")
    }()

    // MARK: - SETUP
    override func setUp() {
        super.setUp()
        let expect = expectation(description: "store init")
        stack = CoreDataStack(type: .memory, model: CoreDataTests.model) {
            switch $0 {
            case .success:
                expect.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 5, handler: { _ in })
    }

    override func tearDown() {
        super.tearDown()
        stack = nil
    }

    // MARK: - TESTS
    func testSQliteStackSetup() {
        if let url = modelUrl {
            let expect = expectation(description: "store init")
            stack = CoreDataStack(type: .sqlite, modelUrl: url) { _ in
                expect.fulfill()
            }
            waitForExpectations(timeout: 5, handler: { _ in })
        }
        XCTAssertNotNil(stack?.persistentStoreCoordinator)
        _ = try? FileManager.default.removeItem(at: stack!.storeURL!)
    }

    func testMemoryStackSetup() {
        if let url = modelUrl {
            let expect = expectation(description: "store init")
            stack = CoreDataStack(type: .memory, modelUrl: url) { _ in
                expect.fulfill()
            }
            waitForExpectations(timeout: 5, handler: { _ in })
        }
        XCTAssertNotNil(stack?.persistentStoreCoordinator)
    }

    func testDefaultContextShouldHaveMainQueueConcurrencyType() {
        XCTAssertTrue(stack?.mainContext.concurrencyType == .mainQueueConcurrencyType)
    }
}
