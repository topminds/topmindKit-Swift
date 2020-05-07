//
//  CoreDataSavingTrait.swift
//  CoreDataMind
//
//  Created by Martin Gratzer on 13/10/15.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
//

import CoreData

public typealias SaveCompletion = (Error?) -> ()

public protocol CoreDataSavingTrait {
    func save(context: NSManagedObjectContext, rollbackOnError: Bool, completion: SaveCompletion?)
}

public protocol CoreDataTrait: CoreDataSavingTrait {
    var mainContext: NSManagedObjectContext { get }
}

public protocol CoreDataNotifications {
    static var saveNotificationName: NSNotification.Name { get }
    static var deleteNotificationName: NSNotification.Name { get }
}

public extension CoreDataSavingTrait {

    func save(context: NSManagedObjectContext, rollbackOnError rollback: Bool = true, completion: SaveCompletion?) {

        context.performAndWait {

            guard context.hasChanges else {
                completion?(nil)
                return
            }

            var savingError: Error?
            var current: NSManagedObjectContext? = context

            repeat {

                guard let context = current else {
                    break
                }

                context.performAndWait {
                    savingError = context.performSave(rollback: rollback)
                }

                current = context.parent

            } while current != nil && savingError == nil

            completion?(savingError)
        }
    }
}

private extension NSManagedObjectContext {

    func performSave(rollback: Bool = true) -> Error? {

        var savingError: Error?
        performAndWait {
            do {
                try self.save()
            } catch {
                // we need to be careful here, error may contain NSManagedObjects which belong
                // to the context's queue, accessing userInfo outside the context's queue can cause crashes!
                // thats the reaseon why we wrap the original error                
                savingError = error
                if rollback {
                    self.rollback()
                }
            }
        }

        return savingError
    }
}
