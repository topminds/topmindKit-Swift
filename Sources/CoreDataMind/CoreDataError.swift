//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public enum CoreDataError: Error {
	case persistenceStoreCreationFailed
	case fileCreationFailed(file: String)
	case entityNotFound(entity: String)
	case entityDescriptionNotFound(entity: String)
	case incorrectType(entity: String)
}
