//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public final class FileLogger: Logger {
	public enum FileLoggerError: Error {
		case CouldNotAccessLogFileDirectory
	}

	public let maxLogfileSize: Int
	public let oldFilesToKeep: Int

	public let fileUrl: URL
	private let formatter: DateFormatter
	private static let fileManager = FileManager.default
	private var fileManager: FileManager {
		FileLogger.fileManager
	}

	public init(file: String = "log.txt", maxLogfileSize: Int = (1024 * 1024), oldFilesToKeep: Int = 3) throws {
		self.maxLogfileSize = maxLogfileSize
		self.oldFilesToKeep = oldFilesToKeep
		fileUrl = FileLogger.filesUrl.appendingPathComponent(file)

		formatter = DateFormatter()
		formatter.dateFormat = "YY-MM-dd HH:mm:ss.SSS"

		if !fileManager.fileExists(atPath: FileLogger.filesUrl.path) {
			try fileManager.createDirectory(at: FileLogger.filesUrl, withIntermediateDirectories: true, attributes: nil)
		}

		// can we rotate log files?
		try rotateLogFile(url: fileUrl)
	}

	public func log(message: String, tag: Log.Tag?, level _: Log.Level) {
		let time = formatter.string(from: Date())
		let logMessage = "\(time): \(formatLogMessage(message: message, tag: tag))\n"
		let logData = logMessage.data(using: .utf8)

		do {
			try logData?.appendToURL(fileURL: fileUrl)
		} catch {
			NSLog("Can not write log file: \(error)")
		}
	}

	public static var filesUrl: URL {
		let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		return urls.last?.appendingPathComponent("Logs", isDirectory: true) ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
	}

	public static var files: [URL] {
		(try? fileManager.contentsOfDirectory(at: filesUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])) ?? []
	}

	private func rotateLogFile(url: URL) throws {
		guard try shouldRotateLogFile(path: url.path) else {
			return
		}

		let dirPath = url.deletingLastPathComponent().path
		let file = url.lastPathComponent
		let ts = Date().timeIntervalSince1970
		let newFileUrl = url.deletingLastPathComponent().appendingPathComponent("\(ts)_\(file)")

		try fileManager.moveItem(at: url, to: newFileUrl)

		try deleteOldLogFiles(path: dirPath, file: file)
	}

	@discardableResult
	private func shouldRotateLogFile(path: String) throws -> Bool {
		guard fileManager.fileExists(atPath: path) else {
			return false
		}

		let attributes = try fileManager.attributesOfItem(atPath: path)
		guard let fileSize = attributes[FileAttributeKey.size] as? Int else {
			return false
		}
		return fileSize > maxLogfileSize
	}

	private func deleteOldLogFiles(path: String, file: String) throws {
		let files = try FileManager.default
			.contentsOfDirectory(atPath: path)
			.filter { $0.hasSuffix(file) }
			.sorted(by: <)

		let remove = files.count - oldFilesToKeep

		guard remove > 0 else {
			return
		}

		for (index, file) in files.enumerated() where index < remove {
			try fileManager.removeItem(atPath: "\(path)/\(file)")
		}
	}
}

private extension Data {
	func appendToURL(fileURL: URL) throws {
		let path = fileURL.path
		if !FileManager.default.fileExists(atPath: path) {
			FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
		}

		guard FileManager.default.isWritableFile(atPath: path) else {
			throw "\(fileURL) is not writeable"
		}

		if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
			defer {
				fileHandle.closeFile()
			}
			fileHandle.seekToEndOfFile()
			fileHandle.write(self)
		} else {
			try write(to: fileURL)
		}
	}
}
