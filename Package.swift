// swift-tools-version:5.7

import PackageDescription

let package = Package(
	name: "topmindKit",
	platforms: [
		.macOS(.v12), .iOS(.v15), .watchOS(.v8), .tvOS(.v15)
	],
	products: [
		.library(name: "AppMind", targets: ["AppMind"]),
		.library(name: "CoreDataMind", targets: ["CoreDataMind"]),
		.library(name: "CoreMind", targets: ["CoreMind"]),
		.library(name: "CryptoMind", targets: ["CryptoMind"]),
		.library(name: "NetMind", targets: ["NetMind"])
	],
	dependencies: [
	],
	targets: [
		.target(name: "AppMind", dependencies: []),
		.testTarget(name: "AppMindTests", dependencies: ["AppMind"]),

		.target(name: "CoreDataMind", dependencies: []),
		.testTarget(name: "CoreDataMindTests", dependencies: ["CoreDataMind"]),

		.target(name: "CoreMind", dependencies: []),
		.testTarget(name: "CoreMindTests", dependencies: ["CoreMind"]),

		.target(name: "CryptoMind", dependencies: []),
		.testTarget(name: "CryptoMindTests", dependencies: ["CryptoMind"]),

		.target(name: "NetMind", dependencies: []),
		.testTarget(name: "NetMindTests", dependencies: ["NetMind"])
	]
)
