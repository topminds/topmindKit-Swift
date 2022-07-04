//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation
import os

public protocol Logger {
	func log(message: String, tag: Log.Tag?, level: Log.Level)
}

public extension Logger {
	func formatLogMessage(message: String, tag: Log.Tag?) -> String {
		guard let tag = tag else {
			return message
		}
		return "[\(tag)] \(message)"
	}
}

public struct ConsoleLogger: Logger {
    private let osLog: OSLog
    
    public init(subsystem: String? = Bundle.main.bundleIdentifier, category: String? = nil) {
        osLog = OSLog(
            subsystem: subsystem ?? "",
            category: category ?? ""
        )
    }
    
	public func log(message: String, tag: Log.Tag?, level: Log.Level) {
        let formattedMessage = formatLogMessage(message: message, tag: tag)
        
        switch level {
            case .error:
                logError(formattedMessage)
                
            case .info:
                logInfo(formattedMessage)
                
            case .verbose:
                logVerbose(formattedMessage)
                
            case .warning:
                logWarning(formattedMessage)
        }
	}

    public func info(_ message: String) {
        log(message, type: .info)
    }

    public func debug(_ message: String) {
        log(message, type: .debug)
    }

    public func error(_ message: String) {
        log(message, type: .error)
    }

    public func fault(_ message: String) {
        log(message, type: .fault)
    }

    private func log(_ message: String, type: OSLogType) {
        os_log("%{public}@", log: osLog, type: type, message)
    }
}
