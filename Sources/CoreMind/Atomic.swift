//
//  Atomic.swift
//  topmindKit
//
//  Created by Martin Gratzer on 28/05/2017.
//  Copyright © 2017 topmind mobile app solutions. All rights reserved.
//

import Foundation

/**
 Atomic type syncs all value mutations on a serial queue.
 Use this type when ever thread safety is a conern.
 */
public final class Atomic<T> {

    private let queue: DispatchQueue
    private var internalValue: T

    public init(_ value: T, queueIdentifier: String = "eu.topmind.kit.atomic") {
        self.queue = DispatchQueue(label: queueIdentifier)
        self.internalValue = value
    }

    public var value: T {
        return queue.sync {
            self.internalValue
        }
    }

    @discardableResult
    public func mutate(_ transform: (inout T) -> ()) -> T {
        return queue.sync {
            transform(&self.internalValue)
            return self.internalValue
        }
    }
}
