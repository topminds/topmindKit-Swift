//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import XCTest
@testable import CoreMind

final class TestLogger: Logger {
    typealias DidLog = (_ message: String, _ tag: Log.Tag?, _ level: Log.Level) -> ()
    var didLog: DidLog?
    func log(message: String, tag: Log.Tag?, level: Log.Level) {
        didLog?(message, tag, level)
    }
}

let testMessage = "Hello Fixture"
let testTag = "World Fixture"

class LogTests: XCTestCase {
    var sutError = TestLogger()
    var sutWarning = TestLogger()
    var sutInfo = TestLogger()
    var sutVerbose = TestLogger()

    override func tearDown() {
        sutError.didLog = nil
        sutWarning.didLog = nil
        sutInfo.didLog = nil
        sutVerbose.didLog = nil
        Log.removeAllLoggers()
        super.tearDown()
    }

    func testErrorLogger() {
        givenErrorLogger()
        givenLogExpectation(logger: sutError, level: .error)

        logError(testMessage, tag: testTag)

        waitForExpectations(timeout: 0.2, handler: nil)
    }

    func testWarningLogger() {
        givenWarningLogger()
        givenLogExpectation(logger: sutWarning, level: .warning)

        logWarning(testMessage, tag: testTag)

        waitForExpectations(timeout: 0.2, handler: nil)
    }

    func testInfoLogger() {
        givenInfoLogger()
        givenLogExpectation(logger: sutInfo, level: .info)

        logInfo(testMessage, tag: testTag)

        waitForExpectations(timeout: 0.2, handler: nil)
    }

    func testVerboseLogger() {
        givenVerboseLogger()
        givenLogExpectation(logger: sutVerbose, level: .verbose)

        logVerbose(testMessage, tag: testTag)

        waitForExpectations(timeout: 0.2, handler: nil)
    }

    func testMultiLevelLoggingVerbose() {
        givenErrorLogger()
        givenWarningLogger()
        givenInfoLogger()
        givenVerboseLogger()

        givenNoLogExpectation(logger: sutError)
        givenNoLogExpectation(logger: sutWarning)
        givenNoLogExpectation(logger: sutInfo)
        givenLogExpectation(logger: sutVerbose, level: .verbose)

        logVerbose(testMessage, tag: testTag)

        waitForExpectations(timeout: 0.2, handler: nil)
    }

    func testMultiLevelLoggingInfo() {
        givenErrorLogger()
        givenWarningLogger()
        givenInfoLogger()
        givenVerboseLogger()

        givenNoLogExpectation(logger: sutError)
        givenNoLogExpectation(logger: sutWarning)
        givenLogExpectation(logger: sutInfo, level: .info)
        givenLogExpectation(logger: sutVerbose, level: .info)

        logInfo(testMessage, tag: testTag)

        waitForExpectations(timeout: 0.2, handler: nil)
    }

    func testMultiLevelLoggingWarning() {
        givenErrorLogger()
        givenWarningLogger()
        givenInfoLogger()
        givenVerboseLogger()

        givenNoLogExpectation(logger: sutError)
        givenLogExpectation(logger: sutWarning, level: .warning)
        givenLogExpectation(logger: sutInfo, level: .warning)
        givenLogExpectation(logger: sutVerbose, level: .warning)

        logWarning(testMessage, tag: testTag)

        waitForExpectations(timeout: 0.2, handler: nil)
    }

    func testMultiLevelLoggingError() {
        givenErrorLogger()
        givenWarningLogger()
        givenInfoLogger()
        givenVerboseLogger()

        givenLogExpectation(logger: sutError, level: .error)
        givenLogExpectation(logger: sutWarning, level: .error)
        givenLogExpectation(logger: sutInfo, level: .error)
        givenLogExpectation(logger: sutVerbose, level: .error)

        logError(testMessage, tag: testTag)

        waitForExpectations(timeout: 0.2, handler: nil)
    }

    func testFormatLogMessageWithTag() {
        let formatted = sutInfo.formatLogMessage(message: "message", tag: "tag")
        XCTAssertEqual(formatted, "[tag] message")
    }

    func testFormatLogMessageWithoutTag() {
        let formatted = sutInfo.formatLogMessage(message: "message", tag: nil)
        XCTAssertEqual(formatted, "message")
    }


    // Mark: Helper
    func givenErrorLogger() {
        Log.addLogger(logger: sutError, level: .error)
    }

    func givenWarningLogger() {
        Log.addLogger(logger: sutWarning, level: .warning)
    }

    func givenInfoLogger() {
        Log.addLogger(logger: sutInfo, level: .info)
    }

    func givenVerboseLogger() {
        Log.addLogger(logger: sutVerbose, level: .verbose)
    }

    func givenLogExpectation(logger: TestLogger, level: Log.Level) {
        let exp = expectation(description: "\(level) should log")
        logger.didLog = { m, t, l in
            XCTAssertEqual(m, testMessage)
            XCTAssertEqual(t, testTag)
            XCTAssertEqual(l, level)
            exp.fulfill()
        }
    }
    
    func givenNoLogExpectation(logger: TestLogger) {
        logger.didLog = { _, _, _ in
            XCTFail("Should not log!")
        }
    }
}
