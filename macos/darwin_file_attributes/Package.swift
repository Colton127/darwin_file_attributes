// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "darwin_file_attributes",
    platforms: [
        .macOS("10.14")
    ],
    products: [
        // The library name uses "-" in place of the "_" in the plugin name.
        .library(name: "darwin-file-attributes", targets: ["darwin_file_attributes"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "darwin_file_attributes",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
