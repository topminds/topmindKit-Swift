//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public protocol ManagedObjectType {
	static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

public extension ManagedObjectType {
	static var defaultSortDescriptors: [NSSortDescriptor] {
		[]
	}
}
