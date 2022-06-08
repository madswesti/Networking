// swift-tools-version:5.6

import PackageDescription

let package = Package(
	name: "Networking",
	platforms: [.iOS(.v13)],
	products: [
		.library(name: "Networking", targets: ["Networking"])
	],
	dependencies: [],
	targets: [
		.target(name: "Networking", dependencies: [])
	]
)
