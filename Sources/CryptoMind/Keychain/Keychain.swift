//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public typealias KeychainData = [String: AnyObject]

public struct Keychain {
	public let service: String
	public let synchronizable: Bool
	public let accessGroup: String?

	public init(service: String, accessGroup: String?, synchronizable: Bool) {
		self.service = service
		self.synchronizable = synchronizable
		#if targetEnvironment(simulator)
			// Keychain access group not supported in simulator
			// All apps have access to keychain by default
			self.accessGroup = nil
		#else
			self.accessGroup = accessGroup
		#endif
	}

	public func items(account: String?) throws -> [KeychainData]? {
		let query = createDefaultQueryWithAccount(account).attributes

		var result: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &result)

		if let error = KeychainStatus.checkStatus(status), status != errSecItemNotFound {
			throw error
		}

		return result as? [KeychainData]
	}

	public func save(secret: String, account: String) throws {
		guard let secret = secret.data(using: .utf8) else {
			throw KeychainStatus.unableToDecodeProvidedData
		}

		return try save(secret: secret, account: account)
	}

	public func save(secret: Data, account: String) throws {
		let query = try createDefaultQueryWithAccount(account)
			.save(secret: secret)
		let status = SecItemAdd(query as CFDictionary, nil)

		if let error = KeychainStatus.checkStatus(status) {
			throw error
		}
	}

	public func secret(account: String) throws -> String {
		let data: Data = try secret(account: account)
		guard let secretString = String(data: data, encoding: .utf8) else {
			throw KeychainStatus.unableToDecodeProvidedData
		}
		return secretString
	}

	public func secret(account: String) throws -> Data {
		let query = createDefaultQueryWithAccount(account).secret

		var secret: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &secret)

		guard let secretData = secret as? Data, status == errSecSuccess else {
			guard let error = KeychainStatus.checkStatus(status) else {
				throw KeychainStatus.unknown
			}
			throw error
		}

		return secretData
	}

	public func change(secret: String, account: String) throws {
		guard let secret = secret.data(using: .utf8) else {
			throw KeychainStatus.unableToDecodeProvidedData
		}

		return try change(secret: secret, account: account)
	}

	public func change(secret: Data, account: String) throws {
		let query = createDefaultQueryWithAccount(account)
		let update = try Query.update(secret: secret)
		let status = SecItemUpdate(query.createKeychainData() as CFDictionary, update as CFDictionary)

		if let error = KeychainStatus.checkStatus(status) {
			throw error
		}
	}

	public func updateOrRemove(string: String?, account: String) throws {
		guard let new = string else {
			try updateOrRemove(data: nil, account: account)
			return
		}

		guard let data = new.data(using: .utf8) else {
			// conversion of Swift String to UTF8 cannot fail
			throw KeychainStatus.unableToDecodeProvidedData
		}

		return try updateOrRemove(data: data, account: account)
	}

	public func updateOrRemove(data: Data?, account: String) throws {
		let exists: Bool
		do {
			_ = try secret(account: account) as Data
			exists = true
		} catch KeychainStatus.itemNotFound {
			exists = false
		} catch {
			throw error
		}

		guard let new = data else {
			// remove if secret is nil
			if exists {
				try delete(account: account)
			}
			return
		}

		if exists {
			try change(secret: new, account: account)
		} else {
			try save(secret: new, account: account)
		}
	}

	public func delete(account: String) throws {
		let query = createDefaultQueryWithAccount(account)
		let status = SecItemDelete(query.createKeychainData() as CFDictionary)

		if let error = KeychainStatus.checkStatus(status) {
			throw error
		}
	}

	public static func resetAllGenericPasswords() throws {
		let query = Query.genericPassword
		let status = SecItemDelete(query as CFDictionary)

		if let error = KeychainStatus.checkStatus(status) {
			throw error
		}
	}

	private func createDefaultQueryWithAccount(_ account: String?) -> Query {
		Query(service: service,
		      account: account,
		      accessGroup: accessGroup,
		      synchronizable: synchronizable)
	}
}

// special keychain reading with plain settings
// query without kSecAttrAccessible
public extension Keychain {
	func secretWithoutAccessibleAttribute(account: String) throws -> String {
		let data: Data = try secretWithoutAccessibleAttribute(account: account)
		guard let secretString = String(data: data, encoding: .utf8) else {
			throw KeychainStatus.unableToDecodeProvidedData
		}
		return secretString
	}

	func secretWithoutAccessibleAttribute(account: String) throws -> Data {
		var query = createDefaultQueryWithAccount(account).secret
		query.removeValue(forKey: Keychain.Attributes.accessible)

		var secret: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &secret)

		guard let secretData = secret as? Data, status == errSecSuccess else {
			guard let error = KeychainStatus.checkStatus(status) else {
				throw KeychainStatus.unknown
			}
			throw error
		}

		return secretData
	}
}
