//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import CoreData

public final class ManagedObjectObserver {
    
    public enum ChangeType {
        case delete
        case update
    }
    
    private var object: NSManagedObject
    private let onChange: (ChangeType) -> ()
    
    private var observer: NSObjectProtocol?
    
    public init(object: NSManagedObject, autoEnabled: Bool = true, onChange: @escaping (ChangeType) -> ()) {
        self.object = object
        self.onChange = onChange
        
        if autoEnabled {
            enable()
        }
    }
    
    deinit {
        disable()
    }
    
    public func enable() {
        guard let context = object.managedObjectContext, observer == nil else {
            return
        }
        observer = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: context, queue: nil) {
            [weak self] in
            
            guard let self = self, let notification = ObjectsDidChangeNotification(notification: $0),
                let changeType = ManagedObjectObserver.changeType(of: self.object, for: notification) else {
                    return
            }
            self.onChange(changeType)
        }
    }
    
    public func disable() {
        guard let observer = observer else {
            return
        }
        NotificationCenter.default.removeObserver(observer)
        self.observer = nil
    }
    
    // MARK: Private
    
    private static func changeType(of object: NSManagedObject, for notification: ObjectsDidChangeNotification) -> ChangeType? {
        if notification.invalidatedAll || notification.deleted.union(notification.invalidated).contains(object) {
            return .delete
        }
        if notification.updated.union(notification.refreshed).contains(object) {
            return .update
        }
        return nil
    }
}
