//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

// Note: It wasn't ale to use <T: AnyObject> in order to avoid type casting inside the class
// last try: Apple Swift version 4.1 (swiftlang-902.0.48 clang-902.0.37.1)

/**

 A collection of delegates enabling a 1:n observeration relation.

 ```
    protocol MyViewModelDelegate: class {
        func didUpdate(state: MyViewModel.State)
    }

    final class MyViewModel {
        private let observers = MulticastDelegate<MyViewModelDelegate>()

        private(set) state = State() {
            didSet {
                observers.invoke {
                    $0.didUpdate(state: State)
                }
            }
        }

        func add(observer: MultiCastMockObserver) {
            observers += observer
        }

        func remove(observer: MultiCastMockObserver) {
            observers -= observer
        }
    }
 ```
 */

public final class MulticastDelegate<T> {
	/// Defines retain modes for referenced observers
	public enum ReferenceMode {
		case weak
		case strong

		fileprivate var pointerOptions: NSPointerFunctions.Options {
			switch self {
			case .strong: return [.strongMemory]
			case .weak: return [.weakMemory]
			}
		}
	}

	public let mode: ReferenceMode
	private var delegates: NSHashTable<AnyObject>

	/// The number of non null multicasting delegates.
	public var count: Int {
		delegates.allObjects.count
	}

	/// A Boolean value indicating whether the list of delegates is empty.
	public var isEmpty: Bool {
		count == 0
	}

	/// Initializer
	///
	/// **Attention:** You are repsonsible to remove observers in .strong mode to avoid potential retain cycles.
	/// - Parameter mode: Defines how observer references are referenced, .weak by default.
	public init(mode: ReferenceMode = .weak) {
		self.mode = mode
		delegates = NSHashTable(options: mode.pointerOptions)
	}

	/// Adds an observer to the list of delegates
	///
	/// - Parameter delegate: The delegate to add
	public func add(delegate: T) {
		remove(delegate: delegate)
		delegates.add(delegate as AnyObject)
	}

	/// Removes an observer from the list of delegates
	///
	/// - Parameter delegate: The delegate to remove
	public func remove(delegate: T) {
		delegates.remove(delegate as AnyObject)
	}

	/// Invokes the given function with all registered delegates
	///
	/// - Parameter invocation: The invocation function to process delegates
	public func invoke(invocation: (T) -> Void) {
		delegates
			.allObjects
			.forEach {
				if let object = $0 as? T {
					invocation(object)
				}
			}
	}

	/// Check if a delegate is already registered
	///
	/// - Parameter delegate: The delegate
	/// - Returns: true if the delegate is already registerd, false otherwise
	public func contains(_ delegate: T) -> Bool {
		delegates.contains(delegate as AnyObject)
	}
}

public func += <T>(left: MulticastDelegate<T>, right: T) {
	left.add(delegate: right)
}

public func -= <T>(left: MulticastDelegate<T>, right: T) {
	left.remove(delegate: right)
}
