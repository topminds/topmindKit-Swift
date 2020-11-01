//
//  Observer.swift
//  topmindKit
//
//  Created by Martin Gratzer on 02/09/2016.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
//

import Foundation

/// Boxing type to provide weak containers
public struct WeakBox {
	/// Weak observer reference
	public private(set) weak var boxed: AnyObject?

	public init(_ object: AnyObject) {
		boxed = object
	}
}

// @available(*, deprecated, message: "Use `MulticastDelegate` for `weak` observing or `Combine`")
public protocol Observer: AnyObject {}

/// Protocol for observable type
// @available(*, deprecated, message: "Use `MulticastDelegate` for `weak` observing or `Combine`")
public protocol Observable: AnyObject {
	/// Observable specific protocol for change callbacks
	/// use observers.forEarch { $0.yourCallback } to notify observers
	associatedtype ObserverType

	/// List of observers
	/// This property has to be public to allow mutation
	/// Associated objects could be a solution but I'd like not to rely
	/// on Objc-C runtime
	var weakObservers: [WeakBox] { get set }
}

public extension Observable {
	/// Adds a new observer to the current observer list
	///
	/// - parameter observer: Observer to add
	func add(observer: Observer) {
		cleanupObservers()

		// Ignore wrong observer types
		// This is a little hack due to Swift's current generic limitations
		// Swift 4 to the rescue?
		guard observer is ObserverType else {
			return
		}

		// do not add observer twice
		let index = weakObservers.firstIndex { $0.boxed === observer }
		guard index == nil else {
			return
		}

		let box = WeakBox(observer)
		weakObservers.append(box)
	}

	/// Removes existing observers, non existing observers are ignored
	///
	/// - parameter observer: Observer to remove, ignored if not found
	func remove(observer: Observer) {
		cleanupObservers()

		let index = weakObservers.firstIndex { $0.boxed === observer }
		guard let observerIndex = index else {
			return
		}
		weakObservers.remove(at: observerIndex)
	}

	/// Conveient list of typed observers
	var observers: [ObserverType] {
		weakObservers.compactMap { $0.boxed as? ObserverType }
	}

	/// Removes deallocated weak observers
	/// This metod is called on each add and remove call
	private func cleanupObservers() {
		weakObservers = weakObservers.filter { $0.boxed != nil }
	}
}

/// Convenience base observer to avoid implementing weakObservers
/// at the cost of subclassing
open class BaseObservable<Observer>: Observable {
	public typealias ObserverType = Observer
	public var weakObservers = [WeakBox]()
	public init() {}
}

open class NSBaseObservable<Observer>: NSObject, Observable {
	public typealias ObserverType = Observer
	public var weakObservers = [WeakBox]()
}
