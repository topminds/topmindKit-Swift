//
//  UIView+Animations.swift
//  AppMind
//
//  Created by Raphael Seher on 07.01.19.
//  Copyright © 2019 topmind mobile app solutions. All rights reserved.
//

#if os(iOS)
import UIKit

extension UIView {
    
    public class func animateWithDefaults(duration: TimeInterval = 0.25,
                                          delay: TimeInterval = 0.0,
                                          options: UIView.AnimationOptions = [.curveEaseOut],
                                          animations: @escaping (() -> Void),
                                          completion: ((Bool) -> Void)? = nil) {
        
        UIView.animate(withDuration: duration,
                       delay: delay,
                       options: options,
                       animations: animations,
                       completion: completion)
    }
    
    public class func animateWithSprings(duration: TimeInterval = 0.5,
                                         delay: TimeInterval = 0.0,
                                         springDamping: CGFloat = 0.8,
                                         initialVelocity: CGFloat = 0.85,
                                         options: UIView.AnimationOptions = [],
                                         animations: @escaping (() -> Void),
                                         completion: ((Bool) -> Void)? = nil) {
        
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: springDamping,
                       initialSpringVelocity: initialVelocity,
                       options: options,
                       animations: animations,
                       completion: completion)
    }
}
#endif
