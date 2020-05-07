//
//  CoreDataFetcheriOS.swift
//  CoreDataMind
//
//  Created by Martin Gratzer on 13/10/15.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
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
