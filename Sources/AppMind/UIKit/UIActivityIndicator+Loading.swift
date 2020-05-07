//
//  UIActivityIndicator+Loading.swift
//  AppMind
//
//  Created by Raphael Seher on 07.01.19.
//  Copyright © 2019 topmind mobile app solutions. All rights reserved.
//

#if os(iOS)
import UIKit

extension UIActivityIndicatorView {
    public var isLoading: Bool {
        get {
            return self.isAnimating
        }
        
        set {
            if newValue {
                self.isHidden = false
                self.startAnimating()
            } else {
                self.stopAnimating()
            }
        }
    }
}
#endif
