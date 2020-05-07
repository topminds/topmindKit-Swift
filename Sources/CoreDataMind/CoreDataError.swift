//
//  CoreDataError.swift
//  CoreDataMind
//
//  Created by Martin Gratzer on 19.11.15.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
//

import Foundation

public enum CoreDataError: Error {
    case persistenceStoreCreationFailed
    case fileCreationFailed(file: String)
    case entityNotFound(entity: String)
    case entityDescriptionNotFound(entity: String)
    case incorrectType(entity: String)
}
