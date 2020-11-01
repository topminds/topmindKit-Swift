//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#if os(iOS) || os(tvOS)
import UIKit

public protocol XibLoadable {
    static var xibName: String { get }
}

extension XibLoadable {

    public static func loadXib(owner: AnyObject? = nil, bundle: Bundle = Bundle.main, builder: ((Self) -> Void)? = nil) -> Self {
        guard let nib = bundle.loadNibNamed(xibName, owner: owner, options: nil)?.first as? Self else {
            fatalError("Unexpected Logic Error. \(xibName) not found.")
        }
        builder?(nib)
        return nib
    }

    public static func nib(bundle: Bundle? = nil) -> UINib {
        return UINib(nibName: xibName, bundle: bundle)
    }
}

public protocol PrototypeCell: class {
    static var cellIdentifier: String { get }
}

extension UITableView {

    public func register<T: PrototypeCell>(cell: T.Type)
        where T: UITableViewCell {
            register(cell, forCellReuseIdentifier: cell.cellIdentifier)
    }

    public func dequeueCell<T: PrototypeCell>(for indexPath: IndexPath) -> T?
        where T: UITableViewCell {
            return dequeueReusableCell(withIdentifier: T.cellIdentifier, for: indexPath) as? T
    }

    public func register<T: XibLoadable>(xibLoadable: T.Type, bundle: Bundle? = nil)
        where T: UITableViewCell {
            register(xibLoadable.nib(bundle: bundle), forCellReuseIdentifier: xibLoadable.xibName)
    }

    public func dequeueCell<T: XibLoadable>(for indexPath: IndexPath) -> T?
        where T: UITableViewCell {
            return dequeueReusableCell(withIdentifier: T.xibName, for: indexPath) as? T
    }
}

extension UICollectionView {
    public func register<T: PrototypeCell>(cell: T.Type)
        where T: UICollectionViewCell {
            register(cell, forCellWithReuseIdentifier: cell.cellIdentifier)
    }

    public func dequeueCell<T: PrototypeCell>(for indexPath: IndexPath) -> T?
        where T: UICollectionViewCell {
            return dequeueReusableCell(withReuseIdentifier: T.cellIdentifier, for: indexPath) as? T
    }

    public func registerCell<T: XibLoadable>(xibLoadable: T.Type, bundle: Bundle? = nil)
        where T: UICollectionViewCell {
            register(xibLoadable.nib(bundle: bundle), forCellWithReuseIdentifier: xibLoadable.xibName)
    }

    public func dequeueCell<T: XibLoadable>(for indexPath: IndexPath) -> T?
        where T: UICollectionViewCell {
            return dequeueReusableCell(withReuseIdentifier: T.xibName, for: indexPath) as? T
    }

    public func registerSupplementaryView<T: XibLoadable>(xibLoadable: T.Type, kind: String, bundle: Bundle? = nil)
        where T: UICollectionReusableView {
            register(xibLoadable.nib(bundle: bundle), forSupplementaryViewOfKind: kind, withReuseIdentifier: xibLoadable.xibName)
    }

    public func dequeueSupplementaryView<T: XibLoadable>(ofKind kind: String, for indexPath: IndexPath) -> T?
        where T: UICollectionReusableView {
            return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.xibName, for: indexPath) as? T
    }
}

#endif
