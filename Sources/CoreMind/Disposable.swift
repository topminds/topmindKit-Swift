//
//  Disposable.swift
//  topmindKit
//
//  Created by Martin Gratzer on 28/05/2017.
//  Copyright © 2017 topmind mobile app solutions. All rights reserved.
//

import Foundation

/**
 Disposable instnce holding a reference via "dispose: () -> ()".

 */
public final class Disposable {

    private let dispose: () -> ()

    init(_ dispose: @escaping () -> ()) {
        self.dispose = dispose
    }

    deinit {
        dispose()
    }
}
