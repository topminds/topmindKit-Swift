//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import CoreData

public func+ (lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
	NSCompoundPredicate(andPredicateWithSubpredicates: [lhs, rhs])
}

public func| (lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
	NSCompoundPredicate(orPredicateWithSubpredicates: [lhs, rhs])
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
		caseInsensitiveSearch(terms as AnyObject, inKeyPaths: inKeyPaths, operation: .in)
	}

	class func caseInsensitiveSearchEqual(_ term: String, inKeyPaths: [String]) -> NSPredicate {
		caseInsensitiveSearch(term as AnyObject, inKeyPaths: inKeyPaths, operation: .equalTo)
	}

	class func caseInsensitiveSearchContains(_ term: String, inKeyPaths: [String]) -> NSPredicate {
		// ensure only strincs are comparedw ith contains
		let paths = inKeyPaths.map { "\($0).description" }
		return caseInsensitiveSearch(term as AnyObject, inKeyPaths: paths, operation: .contains)
	}

	private class func caseInsensitiveSearch(_ term: AnyObject, inKeyPaths: [String], operation: NSComparisonPredicate.Operator) -> NSPredicate {
		let valueExpression = NSExpression(forConstantValue: term)

		var predicates = [NSPredicate]()
		inKeyPaths.forEach {
			let attributeExpression = NSExpression(forKeyPath: $0)
			let predicate = NSComparisonPredicate(leftExpression: attributeExpression,
			                                      rightExpression: valueExpression,
			                                      modifier: .direct,
			                                      type: operation,
			                                      options: .caseInsensitive)
			predicates.append(predicate)
		}

		return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
	}
}
