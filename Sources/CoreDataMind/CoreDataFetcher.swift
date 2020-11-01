//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation
import CoreData

public struct RequestConfig {
    public let predicate: NSPredicate?
    public let sortDescriptors: [NSSortDescriptor]
    public let sectionNameKeyPath: String?
    public let fetchLimit: Int?
    public let includesPropertyValues: Bool

    public init(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor] = [], sectionNameKeyPath: String? = nil, fetchLimit: Int? = nil, includesPropertyValues: Bool = true) {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.sectionNameKeyPath = sectionNameKeyPath
        self.fetchLimit = fetchLimit
        self.includesPropertyValues = includesPropertyValues
    }
}

public struct CoreDataFetcher<T: NSManagedObject> {

    public typealias Entity = T

    public typealias BuilderCallback = (Entity) -> Void
    public typealias CollectionResult = Result<[Entity], Error>
    public typealias EntityResult = Result<Entity, Error>
    public typealias CollectionCompletion = (CollectionResult) -> Void
    public typealias EntityCompletion = (EntityResult) -> Void

    // MARK: - PROPERTIES
    public let context: NSManagedObjectContext
    public let sortDescriptors: [NSSortDescriptor]?

    // MARK: - Init
    public init(context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor]? = nil) {
        self.context = context
        self.sortDescriptors = sortDescriptors
    }

    // MARK: - Single Entity
    public func create(_ builder: BuilderCallback? = nil) -> EntityResult {
        let entity = Entity(context: context)
        builder?(entity)
        return .success(entity)
    }

    public func find(identifier: NSManagedObjectID) -> EntityResult {

        do {
            guard let result = try context.existingObject(with: identifier) as? Entity else {
                return .failure(CoreDataError.entityNotFound(entity: NSStringFromClass(Entity.self)))
            }
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - All
    public func all() -> CollectionResult {
        return all(configuration: configuration())
    }

    public func all(sortedBy sortDescriptors: [NSSortDescriptor]) -> CollectionResult {
        return all(configuration: configuration(predicate: nil, sortDescriptors: sortDescriptors))
    }

    public func all<U: Any>(keyPath: KeyPath<Entity, U>, value: AnyObject) -> CollectionResult {
        all(attribute: NSExpression(forKeyPath: keyPath).keyPath, value: value)
    }

    public func all(attribute: String, value: AnyObject) -> CollectionResult {
        let predicate = NSPredicate(attribute: attribute, value: value, operation: .equal)
        return all(configuration: configuration(predicate: predicate))
    }

    public func all(configuration config: RequestConfig) -> CollectionResult {
        return execute(config)
    }

    // MARK: All async
    public func all(_ completion: @escaping CollectionCompletion) {
        all(configuration: configuration(), completion: completion)
    }

    public func all(sortedBy sortDescriptors: [NSSortDescriptor], completion: @escaping CollectionCompletion) {
        all(configuration: configuration(predicate: nil, sortDescriptors: sortDescriptors), completion: completion)
    }

    public func all<U: Any>(keyPath: KeyPath<Entity, U>, value: AnyObject, completion: @escaping CollectionCompletion) {
        all(attribute: NSExpression(forKeyPath: keyPath).keyPath, value: value, completion: completion)
    }

    public func all(attribute: String, value: AnyObject, completion: @escaping CollectionCompletion) {
        let predicate = NSPredicate(attribute: attribute, value: value, operation: .equal)
        let config = configuration(predicate: predicate)
        all(configuration: config, completion: completion)
    }

    public func all(configuration config: RequestConfig, completion: @escaping CollectionCompletion) {
        context.perform {
            completion(self.execute(config))
        }
    }

    // MARK: - First
    public func first<U: Any>(keyPath: KeyPath<Entity, U>, value: AnyObject) -> EntityResult {
        first(attribute: NSExpression(forKeyPath: keyPath).keyPath, value: value)
    }

    public func first(attribute: String, value: AnyObject) -> EntityResult {
        extractFirst(all(attribute: attribute, value: value))
    }

    public func first(configuration config: RequestConfig) -> EntityResult {
        extractFirst(all(configuration: config))
    }

    public func first<U: Any>(keyPath: KeyPath<Entity, U>, value: AnyObject, completion: @escaping EntityCompletion) {
        first(attribute: NSExpression(forKeyPath: keyPath).keyPath, value: value, completion: completion)
    }

    public func first(attribute: String, value: AnyObject, completion: @escaping EntityCompletion) {
        all(attribute: attribute, value: value) {
            completion(self.extractFirst($0))
        }
    }

    public func firstOrCreate<U: Any>(keyPath: KeyPath<Entity, U>, value: AnyObject, builder: BuilderCallback? = nil) -> EntityResult {
        firstOrCreate(attribute: NSExpression(forKeyPath: keyPath).keyPath, value: value, builder: builder)
    }

    public func firstOrCreate(attribute: String, value: AnyObject, builder: BuilderCallback? = nil) -> EntityResult {
        let predicate = NSPredicate(attribute: attribute, value: value, operation: .equal)
        return firstOrCreate(configuration: configuration(predicate: predicate), builder: builder)
    }

    public func firstOrCreate(configuration config: RequestConfig, builder: BuilderCallback? = nil) -> EntityResult {

        let result = extractFirst(all(configuration: config))
        if case .success(let entity) = result {
            builder?(entity)
            return result
        }
        return create(builder)
    }

    // MARK: - Requests
    public func fetchRequest(configuration config: RequestConfig) -> NSFetchRequest<Entity> {
        let request = NSFetchRequest<Entity>()
        request.entity = Entity.entity()
        update(request: request, config: config)
        return request
    }

    // FIXME: extension on NSFetchRequest<Entity> is not working anymore :-(
    // due to generic NSFetchRequest
    public func update(request: NSFetchRequest<Entity>, config: RequestConfig) {
        request.predicate = config.predicate
        request.sortDescriptors = config.sortDescriptors
        if let limit = config.fetchLimit {
            request.fetchLimit = limit
        }
        request.includesPropertyValues = config.includesPropertyValues
    }

    // MARK: Delete

    public func delete(_ entity: Entity) throws {
        try delete([entity])
    }

    public func delete(_ entities: [Entity]) throws {
        let predicate = NSPredicate(format: "(SELF IN %@)", entities)
        let configuration = RequestConfig(predicate: predicate, includesPropertyValues: false)
        try delete(configuration: configuration)
    }

    public func deleteAll() throws {
        let configuration = RequestConfig(predicate: nil, includesPropertyValues: false)
        try delete(configuration: configuration)
    }

    public func delete(configuration config: RequestConfig) throws {
        let request = fetchRequest(configuration: config)
        let results = try context.fetch(request)
        context.performAndWait {
            for entity in results {
                self.context.delete(entity)
            }
        }
    }

    // When using NSBatchDeleteRequest, changes are not refelected in the context. Calling this method in iOS 9 resets the context.
    // Consumers need to fetch again after calling it. http://stackoverflow.com/a/33534668
    public func batchDelete(configuration config: RequestConfig) throws {
        try context.execute(deleteRequest(configuration: config))
        context.reset()
    }

    // MARK: - Private

    @available(iOS 9.0, OSX 10.11, *)
    private func deleteRequest(configuration config: RequestConfig) -> NSBatchDeleteRequest {
        // swiftlint:disable force_cast
        return NSBatchDeleteRequest(fetchRequest: fetchRequest(configuration: config) as! NSFetchRequest<NSFetchRequestResult>)
        // swiftlint:enable force_cast
    }

    private func execute(_ config: RequestConfig) -> CollectionResult {
        do {
            let request = fetchRequest(configuration: config)
            let result = try context.fetch(request)

            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    private func configuration(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> RequestConfig {
        let sort = (sortDescriptors ?? self.sortDescriptors) ?? []
        return RequestConfig(predicate: predicate, sortDescriptors: sort)
    }

    private func extractFirst(_ result: CollectionResult) -> EntityResult {
        switch result {
        case .success(let entities):
            guard let entity = entities.first else {
                return .failure(CoreDataError.entityNotFound(entity: NSStringFromClass(Entity.self)))
            }
            return .success(entity)

        case .failure(let error):
            return .failure(error)
        }
    }
}
