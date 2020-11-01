//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public protocol Event {
	var name: String { get }
	var attributes: [String: Any] { get }
}

public protocol Trackable {
	var trackableName: String { get }
}

public protocol Recorder {
	var recordedSession: Int { get }
	var recordedTotal: Int { get }
	@discardableResult
	func record(event: Event, trackable: Trackable) -> Bool
}

public final class EventTracker {
	private var recorders: [Recorder] = []

	public init() {}

	public func register(recorders: Recorder...) {
		self.recorders += recorders
	}

	public func removeAll() {
		recorders.removeAll()
	}

	public func track(event: Event, trackable: Trackable) {
		recorders.forEach {
			$0.record(event: event, trackable: trackable)
		}
	}
}
