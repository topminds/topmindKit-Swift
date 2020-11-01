//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#if os(iOS)
import UIKit

public final class KeyboardObserver {

    public struct Info {
        public let frameBegin: CGRect
        public let frameEnd: CGRect
        public let animationCurve: UIView.AnimationCurve
        public let duration: TimeInterval
    }

    public typealias Callback = (Info) -> ()

    public var onWillShow: Callback?
    public var onDidShow: Callback?
    public var onWillHide: Callback?
    public var onDidHide: Callback?
    public var onWillChangeFrame: Callback?
    public var onDidChangeFrame: Callback?

    private(set) public var currentInfo: Info?

    public init() {
        let notifications: [Notification.Name] = [
            UIResponder.keyboardWillShowNotification, UIResponder.keyboardDidShowNotification,
            UIResponder.keyboardWillHideNotification, UIResponder.keyboardDidHideNotification,
            UIResponder.keyboardWillChangeFrameNotification, UIResponder.keyboardDidChangeFrameNotification
        ]

        notifications.forEach {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(KeyboardObserver.handleNotification(_:)),
                                                   name: $0,
                                                   object: nil)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func handleNotification(_ notification: Notification) {

        guard let info = Info(notification: notification) else {
            return
        }

        currentInfo = info

        switch notification.name {
        case UIResponder.keyboardWillShowNotification: onWillShow?(info)
        case UIResponder.keyboardDidShowNotification: onDidShow?(info)
        case UIResponder.keyboardWillHideNotification: onWillHide?(info)
        case UIResponder.keyboardDidHideNotification: onDidHide?(info)
        case UIResponder.keyboardWillChangeFrameNotification: onWillChangeFrame?(info)
        case UIResponder.keyboardDidChangeFrameNotification: onDidChangeFrame?(info)
        default: break
        }
    }
}

extension UIView {
    public static func animateAlongsideKeyboard(info: KeyboardObserver.Info, animations: @escaping (() -> ()), completion: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: info.duration,
                       delay: 0,
                       options: info.animationOptions,
                       animations: animations,
                       completion: completion)
    }
}

extension KeyboardObserver.Info {
    internal init?(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return nil
        }

        frameBegin = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        frameEnd = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero

        animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationCurve ?? .linear

        duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
    }

    public var animationOptions: UIView.AnimationOptions {
        return UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue) << 16)
    }
}
#endif
