//
//  CoreDataExtensions.swift
//  CoreDataMind
//
//  Created by Martin Gratzer on 19.11.15.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
//

// swiftlint:disable type_name

import CoreData

public func+(lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(andPredicateWithSubpredicates: [lhs, rhs])
}

public func|(lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(orPredicateWithSubpredicates: [lhs, rhs])
}

public extension NSPredicate {

    enum PredicateOperator: String {
        case and = "AND"
        case or = "OR"
        case `in` = "IN"
        case equal = "=="
        case notEqual = "!="
        case greaterThan = ">"
        case greaterThanOrEqual = ">="
        case lessThan = "<"
        case lessThanOrEqual = "<="
    }

    convenience init(attribute: String, value: AnyObject, operation: PredicateOperator) {
        self.init(format: "%K \(operation.rawValue) %@", argumentArray: [attribute, value])
    }

    class func caseInsensitiveSearchIn(_ terms: [String], inKeyPaths: [String]) -> NSPredicate {
        return caseInsensitiveSearch(terms as AnyObject, inKeyPaths: inKeyPaths, operation: .in)
    }

    class func caseInsensitiveSearchEqual(_ term: String, inKeyPaths: [String]) -> NSPredicate {
        return caseInsensitiveSearch(term as AnyObject, inKeyPaths: inKeyPaths, operation: .equalTo)
    }

    class func caseInsensitiveSearchContains(_ term: String, inKeyPaths: [String]) -> NSPredicate {
        // ensure only strincs are comparedw ith contains
        let paths = inKeyPaths.map { "\($0).description" }
        return caseInsensitiveSearch(term as AnyObject, inKeyPaths: paths, operation: .contains)
    }

    fileprivate class func caseInsensitiveSearch(_ term: AnyObject, inKeyPaths: [String], operation: NSComparisonPredicate.Operator) -> NSPredicate {
        let valueExpression = NSExpression(forConstantValue: term)

        var predicates = [NSPredicate]()
        inKeyPaths.forEach {
            let attributeExpression = NSExpression(forKeyPath: $0)
            let predicate = NSComparisonPredicate(leftExpression: attributeExpression,
                rightExpression: valueExpression,
                modifier: .direct,
                type: operation,
                options: .caseInsensitive
            )
            predicates.append(predicate)
        }

        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
}
