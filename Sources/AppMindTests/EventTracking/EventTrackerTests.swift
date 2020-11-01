//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import XCTest
import AppMind

struct DummyTrackable: Trackable {

    var trackableName: String {
        return "TestTrackable"
    }
}

final class DummyRecorder: Recorder {

    private(set) var recordedSession = 0
    private(set) var recordedTotal = 0

    func record(event: Event, trackable: Trackable) -> Bool {
        recordedSession += 1
        recordedTotal += 1
        return true
    }
}

enum DummyEvent: Event {
    case A, B, C

    var name: String {
        return "\(self)"
    }

    var attributes: [String: Any] {
        return [:]
    }
}

final class EventTrackerTests: XCTestCase {

    var sut: EventTracker!

    override func setUp() {
        super.setUp()
        sut = EventTracker()
    }

    func testTrackEvent() {

        let recorderOne = DummyRecorder()
        let recorderTwo = DummyRecorder()
        let trackable = DummyTrackable()

        sut.register(recorders: recorderOne, recorderTwo)
        sut.track(event: DummyEvent.A, trackable: trackable)
        sut.track(event: DummyEvent.B, trackable: trackable)
        sut.track(event: DummyEvent.C, trackable: trackable)

        XCTAssertEqual(recorderOne.recordedTotal, 3)
        XCTAssertEqual(recorderTwo.recordedSession, 3)
    }
}
