# topmindKit-Swift
topmindKit is a collection of shared code reused over several years in a wide range of customer projects with a broad base of installations.

topmindKit consists of several modules fulfilling a different common use case or collection of helpful functions. It was initiated as a Objective-C library and migrated to Swift at a time when the community invented a new Json parsing technique every month and everybody wrote their own `Result` and `Future` implementations.

Moving forward version 2.0.0 will contain breaking changes and remove deprecated code and concepts which are part of the standard library and components like CryptoKit, Combine, CoreData and so on. Version 2.0 will also require iOS 13.0+, macOS 10.15+, Mac Catalyst 13.0+, tvOS 13.0+ and watchOS 6.0+ and Swift 5.3.

## Modules

### CoreMind

CoreMind is a collection of lower level concept atomic mutation, concurrent NSOperations, Result and Future types, logging, multi cast delegation, KVO and some bundle and device identifier extensions. 

### NetMind

NetMind provides a abstraction for declarative HTTP `Webservice` implementations.

### CryptoMind

CryptoMind provides simple hashing extension for `String` and `Data` as well as Swift wrappers for key chain access.

### CoreDataMind

CoreDataMind is a thin layer on top of core data to simplify data requests. 

### AppMind

AppMind contains helper for UIKit child container embedding, Xib loading, UIView animations, keyboard observation, event tracking and similar top level and UI related use cases.

# Contributors
[Martin Gratzer](https://github.com/mgratzer), [Denis Andrašec](https://github.com/denrase), [Raphael Seher](https://github.com/raphaelseher), [Peter Benkö](https://github.com/pbenkoe), [Christoph Lederer](https://github.com/ldrr)

# License 
topmindKit is licensed under the [MIT](LICENSE.txt) license.