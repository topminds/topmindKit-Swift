//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#if os(iOS)
	import UIKit

	public extension UIActivityIndicatorView {
		var isLoading: Bool {
			get {
				isAnimating
			}

			set {
				if newValue {
					isHidden = false
					startAnimating()
				} else {
					stopAnimating()
				}
			}
		}
	}
#endif
