//
//  TimeInterval+Extensions.swift
//  topmindKit
//
//  Created by Denis Andrašec on 07.06.17.
//  Copyright © 2017 topmind mobile app solutions. All rights reserved.
//

import Foundation

extension TimeInterval {
    public static let minute: TimeInterval = 60.0
    public static let hour: TimeInterval = 60.0 * minute
    public static let day: TimeInterval = hour * 24
    public static let week: TimeInterval = day * 7
}
