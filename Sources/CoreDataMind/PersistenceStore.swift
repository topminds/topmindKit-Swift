//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import CoreData

/// Store object for core data stack
public final class PersistenceStore: DataStore, ObservableObject {
	/// The current status of this data store
	@Published
	public private(set) var status: DataStoreStatus = .idle

	/// The main persistent container
	public let persistentContainer: NSPersistentContainer

	/// The view context. Only use this on the main thread!
	@MainActor
	public var viewContext: DataStoreContext {
		persistentContainer.viewContext
	}

	/// Returns the URL of the shared model URL
	/// - Parameters:
	///   - modelName: The model name
	///   - bundle: The bundle
	/// - Returns: The `modelName`.momd resource URL in `bundle`
	public static func modelUrl(_ modelName: String, bundle: Bundle) -> URL? {
		bundle.url(forResource: modelName, withExtension: "momd")
	}

	/// Convenience initialiser for the store
	/// - Parameters:
	///   - inMemory: Changes will not be persisted to disk if `true`
	///   - bundle: The Bundle were the model can be found
	///   - modelName: The name of the model
	/// - Throws: An error if the model is not found in the bundle
	public convenience init(inMemory: Bool = false, bundle: Bundle, modelName: String, deleteIncompatibleStores: Bool = false, containerName: String? = nil) throws {
		guard let url = PersistenceStore.modelUrl(modelName, bundle: bundle) else {
			throw DataStoreError.dataModelNotFound("\(modelName).momd")
		}
		try self.init(url: url, inMemory: inMemory, modelName: modelName, deleteIncompatibleStores: deleteIncompatibleStores, containerName: containerName)
	}

	/// Creates a store
	/// - Parameters:
	///   - url: The url to the model file
	///   - inMemory: Changes will not be persisted to disk if `true`
	///   - modelName: The name of the model
	/// - Throws: An error if the model is not found in the bundle
	public convenience init(url: URL, inMemory: Bool = false, modelName: String, deleteIncompatibleStores: Bool = false, containerName: String? = nil) throws {
		guard let model = NSManagedObjectModel(contentsOf: url) else {
			throw DataStoreError.dataModelNotFound("\(url.absoluteString)")
		}

		try self.init(inMemory: inMemory, model: model, modelName: modelName, deleteIncompatibleStores: deleteIncompatibleStores, containerName: containerName)
	}

	/// Creates a store
	/// - Parameters:
	///   - url: The url to the model file
	///   - inMemory: Changes will not be persisted to disk if `true`
	///   - modelName: The name of the model
	/// - Throws: An error if the model is not found in the bundle
	public init(inMemory: Bool = false, model: NSManagedObjectModel, modelName: String, deleteIncompatibleStores: Bool = false, containerName: String? = nil) throws {
		// Register value transformer for query generation token

		persistentContainer = NSPersistentCloudKitContainer(
			name: modelName,
			managedObjectModel: model
		)

		let description: NSPersistentStoreDescription

		if inMemory {
			description = NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
			description.type = NSInMemoryStoreType
		} else {
			let storeURL = NSPersistentContainer
				.defaultDirectoryURL()
				.appendingPathComponent("\(containerName ?? modelName).sqlite")

			if deleteIncompatibleStores {
				try removeStoreIfIncompatible(storeUrl: storeURL, model: model)
			}

			description = NSPersistentStoreDescription(url: storeURL)
			description.type = NSSQLiteStoreType
		}

		persistentContainer.persistentStoreDescriptions = [description]
	}

	/// This method loads the persistentContainer
	/// - Parameter completion: The completion block called when loading is done
	@MainActor
	@discardableResult
	public func load() async throws -> DataStoreStatus {
		guard case .idle = status else {
			return status
		}

		status = .loading
		status = try await withCheckedThrowingContinuation {
			continuation in
			persistentContainer.loadPersistentStores {
				_, error in
				if let error {
					continuation.resume(with: .failure(error))
				} else {
					continuation.resume(with: .success(.loaded))
				}
			}
		}

		viewContext.automaticallyMergesChangesFromParent = true
		viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
		// Pin the viewContext to the current generation token
		try viewContext.setQueryGenerationFrom(.current)

		return status
	}

	public func performBackgroundTask<T>(_ block: @escaping (DataStoreContext) throws -> T) async rethrows -> T {
		try await persistentContainer.performBackgroundTask(block)
	}

	public func destroyLoadedStores() throws {
		guard status == .loaded else {
			return
		}

		let storeCoordinator = persistentContainer.persistentStoreCoordinator

		for store in storeCoordinator.persistentStores where store.type != NSInMemoryStoreType {
			try storeCoordinator.remove(store)
			if let url = store.url {
				try storeCoordinator.destroyPersistentStore(
					at: url,
					ofType: store.type,
					options: nil
				)
				try deleteSqliteFiles(sqliteFileUrl: url)
			}
		}
	}

	/// Removes a local core data store if incompatible with the given model
	/// - Parameter model: The model to check
	/// - Throws: Core Data Error
	private func removeStoreIfIncompatible(storeUrl: URL, model: NSManagedObjectModel) throws {
		guard !Self.isStoreCompatible(storeURL: storeUrl, withModel: model) else {
			return
		}
		try deleteSqliteFiles(sqliteFileUrl: storeUrl)
	}

	/// Deltes storeUrl .sqlite files
	/// - Parameter sqliteFileUrl: The sqlite file
	/// - Throws: File system errors
	private func deleteSqliteFiles(sqliteFileUrl: URL) throws {
		try [
			sqliteFileUrl,
			URL(string: sqliteFileUrl.absoluteString + "-shm"),
			URL(string: sqliteFileUrl.absoluteString + "-wal")
		]
		.compactMap(\.?.path)
		.filter { FileManager.default.fileExists(atPath: $0) }
		.forEach { try FileManager.default.removeItem(atPath: $0) }
	}

	/// Checks if a core data store is compatible with a given model
	/// - Parameters:
	///   - url: The store url
	///   - model: The model
	/// - Returns: True if compatible, false otherwise
	private static func isStoreCompatible(storeURL url: URL?, withModel model: NSManagedObjectModel) -> Bool {
		guard let storeURL = url else {
			return false
		}

		do {
			let storeMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
				ofType: NSSQLiteStoreType,
				at: storeURL,
				options: nil
			)
			return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata)
		} catch {
			return false
		}
	}
}
