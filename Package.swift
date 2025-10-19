// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Core",
    platforms: [
        .macOS("10.15"),
        .iOS("13.0"),
        .tvOS("13.0"),
        .watchOS("6.0")
    ],
    products: [
        .library(name: "Randomizer", targets: ["RandomizerCore"]),
        .library(name: "RandomizeMacro", targets: ["RandomizeMacro"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "510.0.0")
    ],
    targets: [
        .target(
            name: "RandomizerCore",
            path: "Sources/Randomizer"
        ),
        .macro(
            name: "Macros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "RandomizerCore"
            ],
            path: "Sources/Macros"
        ),
        .target(
            name: "RandomizeMacro",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "Macros",
                "RandomizerCore"
            ],
            path: "Sources/Plugin"
        ),
        .testTarget(
            name: "RandomizeTests",
            dependencies: [
                "RandomizerCore",
                "RandomizeMacro"
            ],
            path: "Tests"
        ),
    ]
)

