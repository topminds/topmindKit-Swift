//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import CoreData

public extension NSManagedObjectContext {

    func createChildContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.mergePolicy = NSOverwriteMergePolicy
        context.parent = self
        return context
    }

    func createReadOnlyPrivateContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }

}

public typealias CoreDataInitCompletion = (Result<NSManagedObjectContext, Error>) -> ()

/// Object holiding and handling the complete core data stack
public final class CoreDataStack: CoreDataTrait {

    /**
        NSPersistentStore type used for the core data stack.

        - SQLite: For persisted SQLite based stack
        - Memory: For non persited memory based stack
    */
    public enum StoreType {
        case sqlite
        case memory

        var stringValue: String {
            switch self {
            case .sqlite: return NSSQLiteStoreType
            case .memory: return NSInMemoryStoreType
            }
        }
    }

    /// App Group to store core data file
    public let groupIdentifier: String?
    /// Manaaged object model
    fileprivate let managedObjectModel: NSManagedObjectModel?
    /// Store file name used to save data (note used for TMCoreData.StoreType.Memory stacks)
    public let storeName: String
    /// NSPersistentStore type
    public let storeType: StoreType
    /// NSPersistentStore options
    public let storeOptions: [AnyHashable: Any] = [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true,
        NSSQLitePragmasOption: ["journal_mode": "DELETE"]
    ]

    /// NSPersistentStoreCoordinator
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = self.createPersistentStoreCoordinator()

    fileprivate func createPersistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
        guard let model = self.managedObjectModel else {
            return nil
        }
        return NSPersistentStoreCoordinator(managedObjectModel: model)
    }

    /// URL to the storage file inside the applicationDocumentsDirectory
    public lazy var storeURL: URL? = self.applicationDocumentsDirectory?.appendingPathComponent(self.storeName)

    /**
        Main thread context. Use this context for everything done on the main thread.
        NEVER use this context within a different thread. Use performBlockAndWait or performBlock
        to ensure correct behavior.

        This context is a child context of the savingContext and not directly bound to to the
        persistentStoreCoordinator. Use save(context:wait:) to save changes made to the object
        graph inside this context.
    */
    public lazy var mainContext: NSManagedObjectContext = self.createMainContext()

    fileprivate func createMainContext() -> NSManagedObjectContext {
        assert(Thread.isMainThread, "mainContext can only be accessed on the main thread.")
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
    }

    // MARK: - INIT

    public init(type: StoreType = .sqlite, model: NSManagedObjectModel? = nil, appGroupIdentifier: String? = nil, name: String = "store.sqlite", async: Bool = false, initCompleted: CoreDataInitCompletion? = nil) {

        managedObjectModel = model ?? NSManagedObjectModel.mergedModel(from: nil)
        storeType = type
        groupIdentifier = appGroupIdentifier
        storeName = name

        if async {
            DispatchQueue.main.async {
                let result = self.setupStack(type)
                initCompleted?(result)
            }
        } else {
            let result = setupStack(type)
            initCompleted?(result)
        }
    }

    public convenience init(type: StoreType = .sqlite, modelUrl: URL? = nil, appGroupIdentifier: String? = nil, name: String = "store.sqlite", async: Bool = false, initCompleted: CoreDataInitCompletion? = nil) {

        let model = CoreDataStack.loadManagedObjectModel(modelUrl)
        self.init(type: type, model: model, appGroupIdentifier: appGroupIdentifier, name: name, initCompleted: initCompleted)
    }

    fileprivate func setupStack(_ type: StoreType) -> Result<NSManagedObjectContext, Error> {

        guard let storeCoordinator = persistentStoreCoordinator,
            let url = storeURL else {
                return .failure(CoreDataError.persistenceStoreCreationFailed)
        }

        do {
            try storeCoordinator.addPersistentStore(ofType: type.stringValue, configurationName: nil, at: url, options: storeOptions)
            return .success(mainContext)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Private
    fileprivate static func loadManagedObjectModel(_ modelUrl: URL?) -> NSManagedObjectModel? {
        guard let url = modelUrl else {
            return NSManagedObjectModel.mergedModel(from: nil)
        }
        return NSManagedObjectModel(contentsOf: url)
    }

    fileprivate lazy var applicationDocumentsDirectory: URL? = self.discoverApplicationDocumentsDirectory()

    fileprivate func discoverApplicationDocumentsDirectory() -> URL? {
        let url: URL?
        if let groupIdentifier = groupIdentifier {
            url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
            assert(url != nil, "Enable app group entitlements for: \(groupIdentifier)")
        } else {
            url = applicationSupportDirectory
        }
        return checkDirectory(url)
    }

    fileprivate lazy var applicationSupportDirectory: URL? = self.discoverApplicationSupportDirectory()

    fileprivate func discoverApplicationSupportDirectory() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        return urls.last
    }
}

private extension CoreDataStack {

    func checkDirectory(_ url: URL?) -> URL? {

        guard let url = url else {
            return nil
        }

        if url.isDirectory() {
            return url
        }

        guard let _ = try? createDirectory(url) else {
            assertionFailure("Could not create directory at \(url)")
            return nil // nil URL is handled later, nothing we can ever do here
        }
        return url
    }

    func createDirectory(_ url: URL) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
    }
}

extension URL {

    func isDirectory() -> Bool {
        let properties = try? resourceValues(forKeys: [.isDirectoryKey]).allValues
        guard let isDirectory = properties?[.isDirectoryKey] as? NSNumber, isDirectory.boolValue else {
            return false
        }
        return true
    }
}
