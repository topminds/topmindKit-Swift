//
//  BundleInfo.swift
//  CoreMind
//
//  Created by Martin Gratzer on 22.01.19.
//  Copyright © 2019 topmind mobile app solutions. All rights reserved.
//

import Foundation

public struct BundleInfo {

    public let name: String
    public let bundleIndentifier: String
    public let version: String
    public let build: String

    public init(bundle: Bundle) {
        self.bundleIndentifier = bundle.identifier ?? "eu.topmind.unknown"
        self.version = bundle.versionNumber ?? "0.0"
        self.build = bundle.buildNumber ?? "0"
        self.name = bundle.appName ?? "Unknown"
    }
}
