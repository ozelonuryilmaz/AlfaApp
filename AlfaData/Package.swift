// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlfaData",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AlfaData",
            targets: ["AlfaData"]),
    ],
    dependencies: [
        .package(path: "../AlfaDomain"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.4.0"),
        .package(url: "https://github.com/FuturraGroup/SecurityKit.git", from: "1.7.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AlfaData",
            dependencies: [
                .product(name: "AlfaDomain", package: "AlfaDomain"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "SecurityKit", package: "SecurityKit")
            ]
        ),
        .testTarget(
            name: "AlfaDataTests",
            dependencies: ["AlfaData"]
        ),
    ]
)
