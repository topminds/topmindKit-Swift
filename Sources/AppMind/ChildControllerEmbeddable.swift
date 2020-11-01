//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#if os(iOS)
import UIKit

public protocol ChildControllerEmbeddable {
    var container: UIView { get }
}

extension ChildControllerEmbeddable where Self: UIViewController {

    public func embedd(controller: UIViewController?) {
        guard let controller = controller else {
            return
        }

        addChild(controller)
        controller.willMove(toParent: self)

        controller.view.frame = container.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(controller.view)
        let layout = [
            controller.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: container.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ]
        NSLayoutConstraint.activate(layout)

        controller.didMove(toParent: self)
    }

    public func unembedd(controller: UIViewController?) {
        guard let controller = controller else {
            return
        }

        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        controller.didMove(toParent: nil)
    }

    // Default transition is cross dissolve with 0.25 duration.
    public func transition(from: UIViewController?,
                           to: UIViewController?,
                           duration: Double = 0.25,
                           options: UIView.AnimationOptions = [.curveEaseOut, .transitionCrossDissolve],
                           animations: (() -> Void)? = nil) {

        guard let fromController = from, let toController = to else {
            return
        }
        toController.view.frame = container.bounds

        fromController.willMove(toParent: nil)
        addChild(toController)

        transition(
            from: fromController,
            to: toController, duration: duration,
            options: options,
            animations: animations,
            completion: { _ in
                fromController.didMove(toParent: nil)
                fromController.removeFromParent()

                toController.didMove(toParent: self)
        }
        )
    }
}
#endif
