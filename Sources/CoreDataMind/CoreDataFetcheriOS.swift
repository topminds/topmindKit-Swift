//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import CoreData

#if os(iOS)
public extension CoreDataFetcher {

    func resultsControllerWithPredicate(config: RequestConfig) -> NSFetchedResultsController<Entity> {

        let request = fetchRequest(configuration: config)
        return NSFetchedResultsController(fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: config.sectionNameKeyPath,
            cacheName: nil
        )
    }
}
#endif
