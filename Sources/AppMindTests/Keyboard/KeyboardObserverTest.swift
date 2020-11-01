//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#if os(iOS)
import XCTest
import AppMind

final class KeyboardObserverTest: XCTestCase {

    let sut = Sut()

    override func tearDown() {
        super.tearDown()
        sut.info = nil
    }

    func testCallbackMethods() {
        NotificationCenter.default.post(givenNotification(name: UIResponder.keyboardWillShowNotification))
        XCTAssertNotNil(sut.info)

        sut.info = nil

        NotificationCenter.default.post(givenNotification(name: UIResponder.keyboardDidShowNotification))
        XCTAssertNotNil(sut.info)

        sut.info = nil

        NotificationCenter.default.post(givenNotification(name: UIResponder.keyboardWillHideNotification))
        XCTAssertNotNil(sut.info)

        sut.info = nil

        NotificationCenter.default.post(givenNotification(name: UIResponder.keyboardDidHideNotification))
        XCTAssertNotNil(sut.info)

        sut.info = nil

        NotificationCenter.default.post(givenNotification(name: UIResponder.keyboardWillChangeFrameNotification))
        XCTAssertNotNil(sut.info)

        sut.info = nil

        NotificationCenter.default.post(givenNotification(name: UIResponder.keyboardDidChangeFrameNotification))
        XCTAssertNotNil(sut.info)
    }

    func testInfo() {
        NotificationCenter.default.post(givenNotification(name: UIResponder.keyboardDidChangeFrameNotification))

        XCTAssertEqual(0.1, sut.info?.duration)
        XCTAssertEqual(CGRect(x: 4, y: 3, width: 2, height: 1), sut.info?.frameBegin)
        XCTAssertEqual(CGRect(x: 1, y: 2, width: 3, height: 4), sut.info?.frameEnd)
        XCTAssertEqual(.easeIn, sut.info?.animationCurve)
    }

    private func givenNotification(name: Notification.Name) -> Notification {
        var notfication = Notification(name: name)

        var userInfo: [AnyHashable: Any] = [:]
        userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] = 0.1
        userInfo[UIResponder.keyboardFrameBeginUserInfoKey] = CGRect(x: 4, y: 3, width: 2, height: 1)
        userInfo[UIResponder.keyboardFrameEndUserInfoKey] = CGRect(x: 1, y: 2, width: 3, height: 4)
        userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] = UIView.AnimationCurve.easeIn
        notfication.userInfo = userInfo

        return notfication
    }

    final class Sut {
        let keyboardObserver = KeyboardObserver()

        var info: KeyboardObserver.Info?

        init() {
            let observer = { self.info = $0 }

            keyboardObserver.onWillShow = observer
            keyboardObserver.onDidShow = observer
            keyboardObserver.onWillHide = observer
            keyboardObserver.onDidHide = observer
            keyboardObserver.onWillChangeFrame = observer
            keyboardObserver.onDidChangeFrame = observer
        }
    }
}
#endif
