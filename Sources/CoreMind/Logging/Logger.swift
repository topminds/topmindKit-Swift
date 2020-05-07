//
//  ColsoleLogger.swift
//  topmindKit
//
//  Created by Martin Gratzer on 03/09/2016.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
//

import Foundation

public protocol Logger {
    func log(message: String, tag: Log.Tag?, level: Log.Level)
}

extension Logger {

    public func formatLogMessage(message: String, tag: Log.Tag?) -> String {
        guard let tag = tag else {
            return message
        }
        return "[\(tag)] \(message)"
    }
}

public struct ConsoleLogger: Logger {

    public init() {
    }

    public func log(message: String, tag: Log.Tag?, level: Log.Level) {
        NSLog(formatLogMessage(message: message, tag: tag))
    }
    
}
