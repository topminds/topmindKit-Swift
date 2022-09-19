//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import CoreData.NSManagedObjectContext
import Foundation

/// Type alias to prevent CoreData imports
public typealias DataStoreContext = NSManagedObjectContext

/// Data store errors
public enum DataStoreError: Error {
	case dataModelNotFound(String)
}

/// All possible status of the data store
public enum DataStoreStatus: CustomStringConvertible, Equatable {
	case idle
	case loading
	case failure(Error)
	case loaded

	/// CustomStringConvertible
	public var description: String {
		switch self {
		case .idle: return "idle"
		case .loading: return "loading"
		case let .failure(error): return error.localizedDescription
		case .loaded: return "loaded"
		}
	}

	/// Equatable
	public static func == (lhs: DataStoreStatus, rhs: DataStoreStatus) -> Bool {
		switch (lhs, rhs) {
		case (.idle, .idle), (.loading, .loading), (.failure, .failure), (.loaded, .loaded): return true
		default: return false
		}
	}
}

public protocol DataStore: AnyObject {
	/// The current status of the data store
	var status: DataStoreStatus { get }
	/// The data store context to be used on the main thread
	var viewContext: DataStoreContext { get }
	/// This method loads the persistentContainer store from disk
	/// - Parameter completion: The completion block called when loading is done
	@discardableResult
	func load() async throws -> DataStoreStatus
	/// Performs a background task
	func performBackgroundTask<T>(_ block: @escaping (DataStoreContext) throws -> T) async rethrows -> T
	/// Destroys the loaded persistent store and removes local files
	func destroyLoadedStores() throws
}
