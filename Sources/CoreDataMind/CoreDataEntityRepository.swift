//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import CoreData

public typealias InternalId = NSManagedObjectID
public typealias ExternalId = UUID
public typealias Builder<T> = (T) throws -> Void

/// Error type for the entity repository
public enum EntityRepositoryError: LocalizedError, CustomStringConvertible {
	case entityNotFound(String)

	public var description: String {
		switch self {
		case let .entityNotFound(message):
			return "Entity not found: \(message)"
		}
	}

	public var errorDescription: String? {
		description
	}
}

/// Id type for `EntityWithServerId` entities which have to primary key, a local `NSManagedObjectID` and a server side `Int64`
public enum EntityId: Equatable, Hashable {
	case `internal`(InternalId)
	case external(ExternalId)
}

public protocol Entity where Self: NSManagedObject {}

/// This protocol indicates that an entity has a server side id and can be identified with a `EntityId`
public protocol EntityWithExternalId: Entity {
	/// The entities external id
	var externalId: ExternalId? { get }
}

public extension NSManagedObject {
	var internalId: InternalId {
		objectID
	}
}

/// Repository based on core data
public protocol CoreDataEntityRepository {
	/// The Entity type
	associatedtype Entity: NSManagedObject

	/// The core data context for this repository
	var context: NSManagedObjectContext { get }
}

/// Default implementations for `Repository`
public extension CoreDataEntityRepository {
	/// Creates an empty entity and calls the builder to set initial values
	/// - Parameter builder: An builder closure to setup the entity
	/// - Throws: Core Data Exception
	/// - Returns: The created entity
	@discardableResult
	func create(builder: Builder<Entity>) throws -> Entity {
		let entity = Entity(context: context)
		try builder(entity)
		return entity
	}

	/// Finds an entity based on it's unique id
	/// - Parameter id: The unique id of the entity
	/// - Throws: Core Data Exception
	/// - Returns: The entity for the id
	func find(by id: InternalId) throws -> Entity {
		guard let entity = context.object(with: id) as? Entity else {
			throw EntityRepositoryError.entityNotFound("\(id.uriRepresentation().absoluteString)")
		}
		return entity
	}

	/// Finds the first entity matching `keyPath` = `value` sorted by the given `sortDescriptors`
	/// - Parameters:
	///   - keyPath: The attribute keyPath
	///   - value: The value
	///   - sortDescriptors: The sort descriptors for sorting
	/// - Throws: Core Data Exception
	/// - Returns: The first entity matching the given key-path and value
	func first<U: Any>(keyPath: KeyPath<Entity, U>, value: AnyObject, sortDescriptors: [NSSortDescriptor]? = nil) throws -> Entity? {
		try all(
			keyPath: keyPath,
			value: value,
			sortDescriptors: sortDescriptors,
			fetchLimit: 1
		).first
	}

	/// All entities matching `keyPath` = `value` sorted by the given `sortDescriptors`
	/// - Parameters:
	///   - keyPath: The attribute keyPath
	///   - value: The value
	///   - sortDescriptors: The sort descriptors for sorting
	/// - Throws: Core Data Exception
	/// - Returns: All entities matching the given key-path and value
	func all<U: Any>(keyPath: KeyPath<Entity, U>, value: AnyObject?, sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int? = nil) throws -> [Entity] {
		try all(
			predicate: NSPredicate(format: "%K == %@", argumentArray: [NSExpression(forKeyPath: keyPath).keyPath, value ?? NSNull()]),
			sortDescriptors: sortDescriptors,
			fetchLimit: fetchLimit
		)
	}

	/// All entities sorted by the given `sortDescriptors`
	/// - Parameter sortDescriptors: The sort descriptors for sorting
	/// - Parameter fetchLimit: A optional fetch limit for this
	/// - Throws: Core Data Exception
	/// - Returns: All entities sorted by the given sort descriptor
	func all(sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int? = nil) throws -> [Entity] {
		try context.fetch(
			fetchRequest(sortDescriptors: sortDescriptors, fetchLimit: fetchLimit)
		)
	}

	// Finds the first entity matching the given `predicate` and `sortDescriptors`
	/// - Parameters:
	///   - predicate: The predicate filtering the entity
	///   - sortDescriptors: The sort descriptors for sorting
	/// - Throws: Core Data Exception
	/// - Returns: The first entity matching the given `predicate` and `sortDescriptors`
	func first(predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]? = nil) throws -> Entity? {
		try all(
			predicate: predicate,
			sortDescriptors: sortDescriptors,
			fetchLimit: 1
		).first
	}

	/// All entities matching the given `predicate` sorted by the given `sortDescriptors`
	/// - Parameters:
	///   - predicate: The predicate to apply to the request
	///   - sortDescriptors: The sort descriptors for sorting
	///   - fetchLimit: A optional fetch limit for this request
	/// - Throws: Core Data Exception
	/// - Returns: All entities sorted by the given sort descriptor
	func all(predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int? = nil) throws -> [Entity] {
		try context.fetch(
			fetchRequest(predicate: predicate, sortDescriptors: sortDescriptors, fetchLimit: fetchLimit)
		)
	}

	/// Updates an existing entity and calls the builder to set initial values
	/// - Parameter builder: A builder closure to update the entity
	/// - Parameter id: The unique id of the entity
	/// - Throws: Core Data Exception
	/// - Returns: The entity for the id
	@discardableResult
	func update(with id: InternalId, builder: Builder<Entity>) throws -> Entity {
		let entity = try find(by: id)
		try builder(entity)
		return entity
	}

	/// Deletes a entity or throws `EntityRepositoryError.entityNotFound` error
	/// - Parameter id: The unique local id of the entity
	/// - Throws: `EntityRepositoryError.entityNotFound` if not found or Core Data Exception
	/// - Returns: The entity for the id
	@discardableResult
	func delete(with id: InternalId) throws -> Entity {
		let entity = try find(by: id)
		context.delete(entity)
		return entity
	}

	/// Batch deletes all entities matching the given `predicate`
	/// - Parameter predicate: The predicate to filter
	/// - Throws: Core Data Exception
	/// - Returns: The local ids of all deleted entities
	@discardableResult
	func batchDelete(predicate: NSPredicate?) throws -> [InternalId] {
		let request = NSFetchRequest<NSManagedObjectID>()
		request.entity = Entity.entity()
		request.predicate = predicate
		request.includesSubentities = false
		request.includesPropertyValues = false
		request.includesPendingChanges = false
		request.resultType = .managedObjectIDResultType

		let objectIds = try context.fetch(request)
		if !objectIds.isEmpty {
			let batchDeleteRequest = NSBatchDeleteRequest(objectIDs: objectIds)
			try context.execute(batchDeleteRequest)
		}

		return objectIds
	}

	/// Counts the number of entities
	/// - Parameter predicate: The filter predicate for the count
	/// - Throws: Core Data error
	/// - Returns: The number of entities
	func numberOfEntities(predicate: NSPredicate?) throws -> UInt {
		let request = fetchRequest(predicate: predicate)
		request.includesSubentities = false
		request.includesPropertyValues = false
		request.includesPendingChanges = false
		return UInt(try context.count(for: request))
	}

	/// Creates a fetch request for the entity
	/// - Parameters:
	///   - predicate: The predicate for the fetch request
	///   - sortDescriptors: A list of sort descriptors for the fetch request
	///   - fetchLimit: A optional fetch limit for the request
	///   - builder: A optional builder closure to refine this request
	/// - Returns: The configured fetch request
	func fetchRequest(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int? = nil, builder: (NSFetchRequest<Entity>) -> Void = { _ in }) -> NSFetchRequest<Entity> {
		let request = NSFetchRequest<Entity>()
		request.entity = Entity.entity()
		request.predicate = predicate
		request.sortDescriptors = sortDescriptors
		if let limit = fetchLimit {
			request.fetchLimit = limit
		}
		builder(request)
		return request
	}
}

public extension CoreDataEntityRepository where Entity: EntityWithExternalId {
	/// Finds an entity based on it's unique id
	/// - Parameter id: The unique id of the entity
	func find(by id: ExternalId) throws -> Entity {
		guard let entity = try (first(predicate: NSPredicate(format: "externalId = %@", id.uuidString))) else {
			throw EntityRepositoryError.entityNotFound("\(type(of: Entity.self)).externalId = \(id.uuidString)")
		}
		return entity
	}

	/// Finds an entity based on it's remote or local id
	/// - Parameter id: The entityId (either remote or local
	/// - Throws: An `EntityRepositoryError` or a Core Data Exception
	/// - Returns: The entity if found
	func find(by id: EntityId) throws -> Entity {
		switch id {
		case let .internal(id):
			return try find(by: id)

		case let .external(id):
			return try find(by: id)
		}
	}

	/// Finds an entity for the given id or creates a new one if the entity is not found.
	/// - Parameters:
	///   - id: The id of the entity
	///   - builder: A builder block with the found/created entity
	/// - Throws: Core Data Exception
	/// - Returns: The updated entity
	@discardableResult
	func updateOrCreate(with id: ExternalId, builder: Builder<Entity>) throws -> Entity {
		do {
			let entity = try find(by: id)
			try builder(entity)
			return entity
		} catch EntityRepositoryError.entityNotFound {
			return try create(builder: builder)
		} catch {
			throw error
		}
	}

	/// This method batch deletes all entities with the given server id
	/// - Parameter ids: The list of server ids to delete
	/// - Throws: Core Data Exception
	/// - Returns: The local ids of all deleted entities
	@discardableResult
	func delete(ids: [ExternalId]) throws -> [InternalId] {
		guard !ids.isEmpty else { return [] }
		return try batchDelete(
			predicate: NSPredicate(format: "%K IN (%@)", "externalId", ids.map(\.uuidString))
		)
	}
}
