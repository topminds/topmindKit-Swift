//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import CoreData

public struct ObjectsDidChangeNotification {
	public let inserted: Set<NSManagedObject>
	public let updated: Set<NSManagedObject>
	public let refreshed: Set<NSManagedObject>
	public let deleted: Set<NSManagedObject>
	public let invalidated: Set<NSManagedObject>
	public let invalidatedAll: Bool
	public let context: NSManagedObjectContext

	public init?(notification: Notification) {
		guard notification.name == NSNotification.Name.NSManagedObjectContextObjectsDidChange,
		      let context = notification.object as? NSManagedObjectContext,
		      let userInfo = notification.userInfo else {
			return nil
		}

		inserted = ObjectsDidChangeNotification.objects(from: userInfo, for: NSInsertedObjectsKey)
		updated = ObjectsDidChangeNotification.objects(from: userInfo, for: NSUpdatedObjectsKey)
		refreshed = ObjectsDidChangeNotification.objects(from: userInfo, for: NSRefreshedObjectsKey)
		deleted = ObjectsDidChangeNotification.objects(from: userInfo, for: NSDeletedObjectsKey)
		invalidated = ObjectsDidChangeNotification.objects(from: userInfo, for: NSInvalidatedObjectsKey)
		invalidatedAll = userInfo[NSInvalidatedAllObjectsKey] != nil
		self.context = context
	}

	// Private

	private static func objects(from userInfo: [AnyHashable: Any], for key: String) -> Set<NSManagedObject> {
		guard let objects = userInfo[key] as? Set<NSManagedObject> else {
			return Set()
		}
		return objects
	}
}
