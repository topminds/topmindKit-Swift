//
//  ContextObserver.swift
//  CoreDataMind
//
//  Created by Martin Gratzer on 27/09/15.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
//

import CoreData

public final class ContextObserver<T: NSManagedObject> {

    public typealias Entity = T

    public typealias ChangedEvent = (_ inserted: [Entity]?, _ updated: [Entity]?, _ deleted: [Entity]?) -> ()

    fileprivate let context: NSManagedObjectContext
    fileprivate let persistentStoreCoordinator: NSPersistentStoreCoordinator?
    fileprivate let masterPredicate: NSPredicate
    fileprivate let didChange: ChangedEvent
    fileprivate let keys = [NSInsertedObjectsKey, NSDeletedObjectsKey, NSUpdatedObjectsKey]
    fileprivate var enabled = false
    fileprivate lazy var center = NotificationCenter.default

    public init?(context: NSManagedObjectContext, predicate: NSPredicate? = nil, autoEnable: Bool = true, onChange: @escaping ChangedEvent) {

        let entity = Entity.entity()

        self.context = context
        persistentStoreCoordinator = context.persistentStoreCoordinator

        let entityPredicate = NSPredicate(format: "entity = %@", entity)
        if let predicate = predicate {
            masterPredicate = entityPredicate + predicate
        } else {
            masterPredicate = entityPredicate
        }

        didChange = onChange

        if autoEnable {
            enable()
        }
    }

    deinit {
        disable()
    }

    public func enable() {
        if !enabled {
            center.addObserver(self, selector: #selector(ContextObserver.contextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: context)
            enabled = true
        }
    }

    public func disable() {
        if enabled {
            center.removeObserver(self, name: .NSManagedObjectContextDidSave, object: context)
            enabled = false
        }
    }

    @objc dynamic fileprivate func contextDidSave(_ notification: Notification) {

        guard let context = notification.object as? NSManagedObjectContext,
            let userInfo = notification.userInfo,
            context.persistentStoreCoordinator == persistentStoreCoordinator else {
                return
        }

        var result = [String: [Entity]]()
        keys.forEach {
            if let set = filteredSetForKey(userInfo, key: $0, predicate: masterPredicate) {
                result[$0] = set
            }
        }

        didChange(
            result[NSInsertedObjectsKey],
            result[NSUpdatedObjectsKey],
            result[NSDeletedObjectsKey]
        )
    }

    fileprivate func filteredSetForKey(_ userInfo: [AnyHashable: Any], key: String, predicate: NSPredicate) -> [Entity]? {
        guard let set = userInfo[key] as? Set<NSManagedObject> else {
            return nil
        }

        let result = (set.filter { predicate.evaluate(with: $0) } as? Set<Entity>) ?? []
        return result.count > 0 ? Array(result) : nil
    }
}
