//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public struct KeyValueChange<T> {
    public let old: T
    public let new: T
}

/**
 Disposable for Objective-C's KVO
 */
public final class KeyValueObserver<T>: NSObject {

    public let keyPath: String
    public let object: NSObject

    private var context = 0
    private let callback: (KeyValueChange<T>) -> Void

    public init(object: NSObject, keyPath: String, callback: @escaping (KeyValueChange<T>) -> Void) {

        assert(object.value(forKeyPath: keyPath) is T,
               "Incorrect observation type `\(T.self)` for keypath `\(keyPath)` on object of class `\(NSStringFromClass(object.classForCoder))`.")

        self.object = object
        self.keyPath = keyPath
        self.callback = callback

        super.init()

        object.addObserver(self, forKeyPath: keyPath, options: [.new, .old], context: &context)
    }

    deinit {
        object.removeObserver(self, forKeyPath: keyPath)
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == self.keyPath,
            context == &self.context else {
            assertionFailure("Incorrect observer target.")
            return
        }

        guard let oldValue = change?[.oldKey] as? T,
            let newValue = change?[.newKey] as? T else {
                logWarning("Incorrect observation type `\(T.self)` for keypath `\(self.keyPath)` on object of type `\(NSStringFromClass(self.object.classForCoder))`.", tag: "KeyValueObserver")
                return
        }

        callback(KeyValueChange(old: oldValue, new: newValue))
    }
}
