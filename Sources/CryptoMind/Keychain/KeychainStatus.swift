//
//  KeychainStatus.swift
//  topmindKit
//
//  Created by Martin Gratzer on 10/12/2016.
//  Copyright © 2016 topmind mobile app solutions. All rights reserved.
//

import Foundation

public enum KeychainStatus: Int32, Error {

    case unimplemented = -4
    case ioError = -36
    case fileAllreadyOpenWithWeitePermission = -49
    case oneOrMoreParametersNotValid = -50
    case failedToAllocateMemory = -108
    case userCanceledTheOperation = -128
    case badParameterorInvalidStateForOperaiton = -909
    case internalComponent = -2070
    case keychainNotAvailable = -25291
    case duplicateItem = -25299
    case itemNotFound = -25300
    case interactionNotAllowed = -25308
    case unableToDecodeProvidedData = -26275
    case authFailed = -25293
    case noAccessForItem = -25243 // happens when access gropu is used on simulator
    case weirdSimulatorErrorBackInXcode8 = -34018 // see https://forums.developer.apple.com/thread/64699
    case unknown = 1

    public static func checkStatus(_ status: OSStatus) -> KeychainStatus? {
        guard status != errSecSuccess else {
            return nil
        }

        return KeychainStatus(rawValue: status) ?? KeychainStatus.unknown
    }

    public var message: String {
        return "\(self)"
    }
}
