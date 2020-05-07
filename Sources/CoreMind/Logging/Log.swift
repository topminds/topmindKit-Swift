//
//  Log.swift
//  topmindKit
//
//  Created by Martin Gratzer on 03/09/2016.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
//

import Foundation

public func logError(_ message: String, tag: Log.Tag? = nil) {
    Log.log(message: message, tag: tag, level: .error)
}

public func logWarning(_ message: String, tag: Log.Tag? = nil) {
    Log.log(message: message, tag: tag, level: .warning)
}

public func logInfo(_ message: String, tag: Log.Tag? = nil) {
    Log.log(message: message, tag: tag, level: .info)
}

public func logVerbose(_ message: String, tag: Log.Tag? = nil) {
    Log.log(message: message, tag: tag, level: .verbose)
}

/// Manages loggers
public struct Log {
    private static let queue = DispatchQueue(label: "eu.topmind.kit.log", qos: .utility)

    public typealias Tag = String
    public enum Level {
        case error, warning, info, verbose

        var included: [Level] {
            switch self {
            case .error:
                return [.error]
            case .warning:
                return [.error, .warning]
            case .info:
                return [.error, .warning, .info]
            case .verbose:
                return [.error, .warning, .info, .verbose]
            }
        }

        func includes(level: Level) -> Bool {
            return included.contains(level)
        }
    }

    private(set) public static var loggers = [Level: [Logger]]()
    public static var level = Level.warning

    public static func addLogger(logger: Logger, level: Level) {
        queue.async {
            var loggers = self.loggers[level] ?? [Logger]()
            loggers.append(logger)
            self.loggers[level] = loggers
        }
    }

    public static func log(message: String, tag: Log.Tag?, level: Level) {
        queue.async {
            for (loggerLevel, loggers) in self.loggers where loggerLevel.includes(level: level) {
                loggers.forEach {
                    $0.log(message: message, tag: tag, level: level)
                }
            }
        }
    }

    public static func removeAllLoggers(level: Level? = nil) {
        queue.async {
            if let level = level {
                loggers.removeValue(forKey: level)
            } else {
                loggers.removeAll()
            }
        }
    }
}
