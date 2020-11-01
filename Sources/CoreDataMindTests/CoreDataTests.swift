//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import XCTest
import CoreData
@testable import CoreDataMind

@objc(Kitten)
class Kitten: NSManagedObject {
    @NSManaged var name: String
}

class CoreDataTests: XCTestCase {

    var kittens: CoreDataFetcher<Kitten>!
    var stack: CoreDataStack?

    static let kittenEntity: NSEntityDescription = {
        let entity = NSEntityDescription()
        entity.name = "Kitten"
        entity.managedObjectClassName = NSStringFromClass(Kitten.self)

        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType

        entity.properties = [ nameAttribute ]

        return entity
    }()

    static let model: NSManagedObjectModel = {
        let model = NSManagedObjectModel()
        model.entities = [ kittenEntity ]
        return model
    }()

    var tom: Kitten?
    var jerry: Kitten? // technically a mouse, but serves the purpose for now

    override func setUp() {
        super.setUp()
        let expect = expectation(description: "store init")
        stack = CoreDataStack(type: .sqlite, model: CoreDataTests.model) { _ in
            expect.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)

        let context = stack!.mainContext

        kittens = CoreDataFetcher<Kitten>(context: context)

        tom = createKittenWithName("Tom")
        jerry = createKittenWithName("Jerry")

        XCTAssertDoesNotThrow(stack!.save(context: context, completion: { _ in }))
    }

    override func tearDown() {
        if let storeUrl = stack?.storeURL {
            do {
                try FileManager.default.removeItem(at: storeUrl)
            } catch {
                XCTFail()
            }
        }
        stack = nil
        super.tearDown()
    }

    func createKittenWithName(_ name: String) -> Kitten? {
        let result = kittens.create { $0.name = name }
        switch result {
            case .success(let kitten):
            return kitten

            case .failure(let error):
            XCTFail(error.localizedDescription)
            return nil
        }
    }

}
