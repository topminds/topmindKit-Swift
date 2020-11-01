//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#if os(macOS)
import XCTest
@testable import CryptoMind

extension Keychain {
    func clean() {
        for item in try! items(account: nil) ?? [] {
            guard let account = item[kSecAttrAccount as String] as? String else {
                continue
            }
            do {
                try delete(account: account)
            } catch {}
        }
    }
}

final class KeychainTests: XCTestCase {
    
    let secretData = "c00k!e".data(using: .utf8)
    let secretData2 = "c00k!e2".data(using: .utf8)

    let sut = Keychain(service: "eu.topmind.topmindKit.CryptoMind", accessGroup: nil, synchronizable: false)

    override func setUp() {
        super.setUp()
        // clean keychain
        sut.clean()
    }

    override class func tearDown() {
        Keychain(service: "eu.topmind.topmindKit.CryptoMind", accessGroup: nil, synchronizable: false).clean()
        super.tearDown()
    }

    func testKeychainShouldSaveSecretString() {
        do {
            try sut.save(secret: "c00k!e", account: "monster")
            let secret: String = try sut.secret(account: "monster")
            XCTAssertEqual("c00k!e", secret)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testKechainShouldChangSavedSecretString() {
        do {
            try sut.save(secret: "c00k!e", account: "monster")
            try sut.change(secret: "cookie", account: "monster")

            let secret: String = try sut.secret(account: "monster")
            XCTAssertEqual("cookie", secret)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testKeychainShouldSaveSecretData() {
        do {
            try sut.save(secret: secretData!, account: "monster")
            let secret: Data = try sut.secret(account: "monster")
            XCTAssertEqual(secretData, secret)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testKechainShouldChangSavedSecretData() {
        do {
            try sut.save(secret: secretData!, account: "monster")
            try sut.change(secret: secretData2!, account: "monster")

            let secret: Data = try sut.secret(account: "monster")
            XCTAssertEqual(secretData2, secret)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testKeychainShouldDelteSavedSecret() {
        do {
            try sut.save(secret: "c00k!e", account: "monster")
            try sut.delete(account: "monster")

            let _: String = try sut.secret(account: "monster")
            XCTFail("Should throw ItemNotFound")
        } catch let error as KeychainStatus {
            XCTAssertEqual(error, KeychainStatus.itemNotFound)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testKeychainShouldListItems() {
        do {
            try sut.save(secret: "c00k!e", account: "monster")
            try sut.save(secret: "l4$4gn3", account: "garfield")

            let items = try sut.items(account: nil)
            let names = items?.compactMap { $0[kSecAttrAccount as String] as? String }
            XCTAssertEqual(["monster", "garfield"], names ?? [])
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testKeychainShouldSaveString() {
        do {
            try sut.updateOrRemove(string: "nomnomnom", account: "monster")
            
            let value: String = try sut.secret(account: "monster")
            XCTAssertEqual("nomnomnom", value)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testKeychainShouldUpdateString() {
        do {
            try sut.save(secret: "c00k!e", account: "monster")
            try sut.updateOrRemove(string: "nomnomnom", account: "monster")
            
            let value: String = try sut.secret(account: "monster")
            XCTAssertEqual("nomnomnom", value)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testKeychainShouldDeleteStringInsteadOfUpdate() {
        do {
            try sut.save(secret: "c00k!e", account: "monster")
            try sut.updateOrRemove(string: nil, account: "monster")
            
            let _: String = try sut.secret(account: "nomnomnom")
            XCTFail("Should throw ItemNotFound")
        } catch let error as KeychainStatus {
            XCTAssertEqual(error, KeychainStatus.itemNotFound)
        } catch {
            XCTFail("\(error)")
        }
    }
    
}
#endif
