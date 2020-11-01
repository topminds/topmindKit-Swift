//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

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
	public init() {}

	public func log(message: String, tag: Log.Tag?, level _: Log.Level) {
		NSLog(formatLogMessage(message: message, tag: tag))
	}
}
