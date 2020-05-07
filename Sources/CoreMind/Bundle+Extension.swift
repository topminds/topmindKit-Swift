//
//  Bundle+Extension.swift
//  CoreMind
//
//  Created by Martin Gratzer on 22.01.19.
//  Copyright © 2019 topmind mobile app solutions. All rights reserved.
//

import Foundation

extension Bundle {

    public var appName: String? {
        return infoDictionary?["CFBundleName"] as? String
    }

    public var identifier: String? {
        return bundleIdentifier
    }

    public var versionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    public var buildNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }

}
