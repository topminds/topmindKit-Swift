//
//  ManagedObjectType.swift
//  CoreDataMind
//
//  Created by Martin Gratzer on 12.01.16.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
//

import Foundation

public protocol ManagedObjectType {
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

public extension ManagedObjectType {

    static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }

}
