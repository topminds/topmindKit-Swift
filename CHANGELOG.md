# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]

## 1.2.1 - 2020-11-07

- Fix `import Combine` build issue with versions lower than iOS13 (#11)

## 1.2.0 - 2020-11-01

This is a non functional release with the focus on preparing the library for open source. Project cleanup, licensing, linting and code formatting.

- Put default file header into .swiftformat configuration (#7)
- Linting and code formatting rules (#6)
- Add MIT license (#5)
- Add KeyPath based fetch methods for type safe attribute selection (#4)

## 1.1.0 - 2020-05-07

This is the initial "release" of topmindKit and a compatibility version for existing apps and @topminds projects before moving on to v2.0 removing deprecated methods and code that has meanwhile been integrated into the Swift language (like Codable, CryptoKit and Result).

- Setup GH action for CI and testing (#3)
- Fix Cocoapods module mapping for CommonCrypto  (#2)
- Fix typo and rename Webserivce to Webservice  (#1)
