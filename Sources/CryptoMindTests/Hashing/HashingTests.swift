//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import CryptoMind
import XCTest

final class HashingTests: XCTestCase {
	// MARK: Simple

	func testMD2Hash() {
		XCTAssertEqual("19ef609c2d7dd8e24776be2ba948d5b9", "iTranslate".md2)
	}

	func testMD4Hash() {
		XCTAssertEqual("428fe1afaeffe6387aa6fa407a110b1c", "iTranslate".md4)
	}

	func testMD5Hash() {
		XCTAssertEqual("93da14e22680d27e44a9cce191726307", "iTranslate".md5)
	}

	func testSHA1Hash() {
		XCTAssertEqual("5201bba0064c5821951bf6ba144cb703f95d0f94", "iTranslate".sha1)
	}

	func testSHA224Hash() {
		XCTAssertEqual("ff966b3415ae49fabcb1eb98702ce9252f4ed3e0883fa805af7d4b20", "iTranslate".sha224)
	}

	func testSHA256Hash() {
		XCTAssertEqual("f5e2f1ad4e4dceac2a575046deccd2d9f7e489fab81982076e2e20b32e722c79", "iTranslate".sha256)
	}

	func testSHA384Hash() {
		XCTAssertEqual("e0fc6e2a856d374d8ed5a76dc64e0e3157d99865bc3d675b57282de36a4b5a40e4e3f2ce2603e79e8ed8c6fdcd776391", "iTranslate".sha384)
	}

	func testSHA512Hash() { XCTAssertEqual("d9861752553eca21f05b5b210244b0aa394c90b082c71615fefa1e9ed41b176f916fc2e005d776943c4fecd0f11ad9d9b7ad2ed5995a44ae1a162f2fcc141b1c", "iTranslate".sha512)
	}

	// MARK: special characters

	func testMD2HashUnicode() {
		XCTAssertEqual("b1e58e8f09666a5ef15f500c0f54ab68", "iTränslaté ❤翻译".md2)
	}

	func testMD4HashUnicode() {
		XCTAssertEqual("2a0fc2d5d13dbc9c96c7172ee8e60b43", "iTränslaté ❤翻译".md4)
	}

	func testMD5HashUnicode() {
		XCTAssertEqual("dc7c40592906bb670f48214a32c3c75b", "iTränslaté ❤翻译".md5)
	}

	func testSHA1HashUnicode() {
		XCTAssertEqual("6778015348cf6d609c0886bd5fd7f69dd25ce1f3", "iTränslaté ❤翻译".sha1)
	}

	func testSHA224HashUnicode() {
		XCTAssertEqual("9f6e92922219db8b09766735466c68e6ecf086bddc37a84d9763c975", "iTränslaté ❤翻译".sha224)
	}

	func testSHA256HashUnicode() {
		XCTAssertEqual("4519d140fe42c774bdfb8874b860467e70b6ea1d6816b971a232b3a26fccf761", "iTränslaté ❤翻译".sha256)
	}

	func testSHA384HashUnicode() {
		XCTAssertEqual("08cd051fb3edf8187e11894ddc86de0c9bd2af81fc3f10ec270cd0e55d847b387b16c3a6dc5b1f2aba40ffe8829713cc", "iTränslaté ❤翻译".sha384)
	}

	func testSHA512HashUnicode() {
		XCTAssertEqual("cd314c8aecc62017c6bbfc20228bb4ac348304f8db1c3c34cfcad21e99f917eb11150309fce4b0799bd54bfd156cbb85002ed2936fd0c18dcbfd4a5ff018f6d9", "iTränslaté ❤翻译".sha512)
	}

	// MARK: boundary test for empty strings

	func testMD2HashEmpty() {
		XCTAssertEqual("8350e5a3e24c153df2275c9f80692773", "".md2)
	}

	func testMD4HashEmpty() {
		XCTAssertEqual("31d6cfe0d16ae931b73c59d7e0c089c0", "".md4)
	}

	func testMD5HashEmpty() {
		XCTAssertEqual("d41d8cd98f00b204e9800998ecf8427e", "".md5)
	}

	func testSHA1HashEmpty() {
		XCTAssertEqual("da39a3ee5e6b4b0d3255bfef95601890afd80709", "".sha1)
	}

	func testSHA224HashEmpty() {
		XCTAssertEqual("d14a028c2a3a2bc9476102bb288234c415a2b01f828ea62ac5b3e42f", "".sha224)
	}

	func testSHA256HashEmpty() {
		XCTAssertEqual("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", "".sha256)
	}

	func testSHA384HashEmpty() {
		XCTAssertEqual("38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b", "".sha384)
	}

	func testSHA512HashEmpty() {
		XCTAssertEqual("cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e", "".sha512)
	}

	// MD5 Test Vectors

	func testMD5TestVectors() {
		XCTAssertEqual("d41d8cd98f00b204e9800998ecf8427e", "".md5)
		XCTAssertEqual("0cc175b9c0f1b6a831c399e269772661", "a".md5)
		XCTAssertEqual("900150983cd24fb0d6963f7d28e17f72", "abc".md5)
		XCTAssertEqual("f96b697d7cb7938d525a2f31aaf161d0", "message digest".md5)
		XCTAssertEqual("c3fcd3d76192e4007dfb496cca67e13b", "abcdefghijklmnopqrstuvwxyz".md5)
		XCTAssertEqual("d174ab98d277d9f5a5611c2c9f419d9f", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".md5)
		XCTAssertEqual("57edf4a22be3c955ac49da2e2107b67a", "12345678901234567890123456789012345678901234567890123456789012345678901234567890".md5)
	}
}
