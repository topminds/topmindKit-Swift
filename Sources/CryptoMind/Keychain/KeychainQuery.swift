//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

extension Keychain {
	enum Attributes {
		static let valueData = kSecValueData as String
		static let returnData = kSecReturnData as String
		static let returnAttributes = kSecReturnAttributes as String
		static let matchLimit = kSecMatchLimit as String
		static let secClass = kSecClass as String
		static let account = kSecAttrAccount as String
		static let service = kSecAttrService as String
		static let synchronizable = kSecAttrSynchronizable as String
		static let accessible = kSecAttrAccessible as String
		static let accessGroup = kSecAttrAccessGroup as String
	}

	struct Query {
		let service: String
		let account: String?
		let synchronizable: Bool
		let accessGroup: String?

		init(service: String, account: String?, accessGroup: String?, synchronizable: Bool) {
			self.service = service
			self.account = account
			self.accessGroup = accessGroup
			self.synchronizable = synchronizable
		}

		func save(secret: Data) throws -> KeychainData {
			createKeychainData([
				Attributes.valueData: secret as AnyObject
			])
		}

		static func update(secret: Data) throws -> KeychainData {
			[Attributes.valueData: secret as AnyObject]
		}

		var secret: KeychainData {
			createKeychainData([
				Attributes.returnData: true as AnyObject
			])
		}

		var attributes: KeychainData {
			createKeychainData([
				Attributes.returnAttributes: true as AnyObject,
				Attributes.matchLimit: kSecMatchLimitAll
			])
		}

		static var genericPassword: KeychainData {
			[
				Attributes.secClass: kSecClassGenericPassword
			]
		}

		func createKeychainData(_ attributes: KeychainData = [:]) -> KeychainData {
			var query = Query.genericPassword

			if let account = account {
				query[Attributes.account] = account as AnyObject?
			}

			query[Attributes.service] = service as AnyObject?

			if synchronizable {
				query[Attributes.synchronizable] = kCFBooleanTrue
			}

			query[Attributes.accessible] = kSecAttrAccessibleAfterFirstUnlock

			if let group = accessGroup {
				query[Attributes.accessGroup] = group as AnyObject?
			}

			for (k, v) in attributes {
				query[k] = v
			}

			return query
		}
	}
}
