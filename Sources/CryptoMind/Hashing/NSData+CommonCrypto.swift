//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// swiftlint:disable variable_name

import Foundation
import CommonCrypto

extension Data {

	// MARK: - Hashing

    public var md2: Data {
        return digest(Digest.md2)
    }

    public var md4: Data {
        return digest(Digest.md4)
    }

    public var md5: Data {
        return digest(Digest.md5)
    }

    public var sha1: Data {
        return digest(Digest.sha1)
    }

    public var sha224: Data {
        return digest(Digest.sha224)
    }

    public var sha256: Data {
        return digest(Digest.sha256)
    }

    public var sha384: Data {
        return digest(Digest.sha384)
    }

    public var sha512: Data {
        return digest(Digest.sha512)
    }

    private func digest(_ function: ((UnsafeRawBufferPointer, UInt32) -> [UInt8])) -> Data {
        var hash: [UInt8] = []
        withUnsafeBytes { hash = function($0, UInt32(count)) }
        return Data(bytes: hash, count: hash.count)
    }

    // MARK: - Internal

    var hex: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

public struct Digest {
    public static func md2(bytes: UnsafeRawBufferPointer, length: UInt32) -> [UInt8] {
        var hash = [UInt8](repeating: 0, count: Int(CC_MD2_DIGEST_LENGTH))
        CC_MD2(bytes.baseAddress, length, &hash)
        return hash
    }

    public static func md4(bytes: UnsafeRawBufferPointer, length: UInt32) -> [UInt8] {
        var hash = [UInt8](repeating: 0, count: Int(CC_MD4_DIGEST_LENGTH))
        CC_MD4(bytes.baseAddress, length, &hash)
        return hash
    }

    public static func md5(bytes: UnsafeRawBufferPointer, length: UInt32) -> [UInt8] {
        var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(bytes.baseAddress, length, &hash)
        return hash
    }

    public static func sha1(bytes: UnsafeRawBufferPointer, length: UInt32) -> [UInt8] {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CC_SHA1(bytes.baseAddress, length, &hash)
        return hash
    }

    public static func sha224(bytes: UnsafeRawBufferPointer, length: UInt32) -> [UInt8] {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA224_DIGEST_LENGTH))
        CC_SHA224(bytes.baseAddress, length, &hash)
        return hash
    }

    public static func sha256(bytes: UnsafeRawBufferPointer, length: UInt32) -> [UInt8] {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(bytes.baseAddress, length, &hash)
        return hash
    }

    public static func sha384(bytes: UnsafeRawBufferPointer, length: UInt32) -> [UInt8] {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA384_DIGEST_LENGTH))
        CC_SHA384(bytes.baseAddress, length, &hash)
        return hash
    }

    public static func sha512(bytes: UnsafeRawBufferPointer, length: UInt32) -> [UInt8] {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        CC_SHA512(bytes.baseAddress, length, &hash)
        return hash
    }
}

public struct HMAC {

    // MARK: - Types

    public enum Algorithm {
        case sha1
        case md5
        case sha256
        case sha384
        case sha512
        case sha224

        public var algorithm: CCHmacAlgorithm {
            switch self {
            case .md5: return CCHmacAlgorithm(kCCHmacAlgMD5)
            case .sha1: return CCHmacAlgorithm(kCCHmacAlgSHA1)
            case .sha224: return CCHmacAlgorithm(kCCHmacAlgSHA224)
            case .sha256: return CCHmacAlgorithm(kCCHmacAlgSHA256)
            case .sha384: return CCHmacAlgorithm(kCCHmacAlgSHA384)
            case .sha512: return CCHmacAlgorithm(kCCHmacAlgSHA512)
            }
        }

        public var digestLength: Int {
            switch self {
            case .md5: return Int(CC_MD5_DIGEST_LENGTH)
            case .sha1: return Int(CC_SHA1_DIGEST_LENGTH)
            case .sha224: return Int(CC_SHA224_DIGEST_LENGTH)
            case .sha256: return Int(CC_SHA256_DIGEST_LENGTH)
            case .sha384: return Int(CC_SHA384_DIGEST_LENGTH)
            case .sha512: return Int(CC_SHA512_DIGEST_LENGTH)
            }
        }
    }

    // MARK: - Signing

    public static func sign(data: Data, algorithm: Algorithm, key: Data) -> Data {
        let signature = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: algorithm.digestLength)

        data.withUnsafeBytes { dataBytes in
            key.withUnsafeBytes { keyBytes in
                CCHmac(algorithm.algorithm, keyBytes.baseAddress, key.count, dataBytes.baseAddress, data.count, signature)
            }
        }

        return Data(bytes: signature, count: algorithm.digestLength)
    }

    public static func sign(message: String, algorithm: Algorithm, key: String) -> String? {
        guard let messageData = message.data(using: .utf8),
            let keyData = key.data(using: .utf8)
            else { return nil }

        return sign(data: messageData, algorithm: algorithm, key: keyData).hex
    }
}
