//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

public struct DeviceInfo {

    public let model: String
    public let name: String
    public let operatingSystem: String
    public let bundle: BundleInfo
    public static var iCloudEnabled: Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }

    public init(bundle: Bundle = .main) {
        self.bundle = BundleInfo(bundle: bundle)

        #if os(iOS) || os(tvOS)
        let device = UIDevice.current
        self.model = DeviceInfo.deviceName() ?? device.model
        self.operatingSystem = "\(device.systemName)/\(device.systemVersion)"
        self.name = device.name
        #elseif os(watchOS)
        let device = WKInterfaceDevice.current()
        self.model = device.model
        self.operatingSystem = "\(device.systemName)/\(device.systemVersion)"
        self.name = device.name
        #elseif os(OSX)
        let info = ProcessInfo.processInfo
        self.model = DeviceInfo.sysctlWithName("hw.machine")
        self.operatingSystem = info.operatingSystemVersionString
        self.name = Host.current().localizedName ?? "unknown host"
        #endif
    }

    // eg. com.company.MyApp/1 rv:123 (iPhone5,2 iOS/12.0 CFNetwork/808.3 Darwin/16.3.0)
    public func userAgentString() -> String {
        return "\(appNameAndVersion(bundleInfo: bundle)) (\(model) \(operatingSystem) \(DeviceInfo.CFNetworkVersion()) \(DeviceInfo.darwinVersion()))"
    }

    //eg. iPhone5,2
    private static func deviceName() -> String? {
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
        guard let s = String(bytes: data, encoding: .ascii) else {
            return nil
        }
        return s.trimmingCharacters(in: .controlCharacters)
    }

    fileprivate static func sysctlWithName(_ name: String) -> String {
        var size = 0
        sysctlbyname(name, nil, &size, nil, 0)

        var value = [CChar](repeating: 0, count: Int(size))
        sysctlbyname(name, &value, &size, nil, 0)

        return String(cString: value)
    }

    //eg. Darwin/16.3.0
    public static func darwinVersion() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        let dv = String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        return "Darwin/\(dv)"
    }

    //eg. CFNetwork/808.3
    public static func CFNetworkVersion() -> String {
        let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary
        let version = dictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
        return "CFNetwork/\(version)"
    }

    //eg. com.company.MyApp/1
    public func appNameAndVersion(bundleInfo: BundleInfo) -> String {
        let version = bundleInfo.version
        let name = bundle.bundleIndentifier
        return "\(name)/\(version) rv:\(bundle.build)"
    }

}
