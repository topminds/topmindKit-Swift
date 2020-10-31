//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
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
