// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlfaData",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AlfaData",
            targets: ["AlfaData"]),
    ],
    dependencies: [
        .package(path: "../AlfaDomain"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.4.0"),
        .package(url: "https://github.com/FuturraGroup/SecurityKit.git", from: "1.7.0"),
        .package(url: "https://github.com/securevale/swift-confidential.git", .upToNextMinor(from: "0.4.0")),
        //.package(url: "https://github.com/securevale/swift-confidential-plugin.git", .upToNextMinor(from: "0.4.0"))
    ],
    targets: [
        .target(
            name: "AlfaData",
            dependencies: [
                .product(name: "AlfaDomain", package: "AlfaDomain"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "SecurityKit", package: "SecurityKit"),
                .product(name: "ConfidentialKit", package: "swift-confidential")
            ],
            //exclude: ["confidential.yml"],
            //plugins: [
            //    .plugin(name: "Confidential", package: "swift-confidential-plugin")
            //]
        ),
        .testTarget(
            name: "AlfaDataTests",
            dependencies: ["AlfaData"]
        ),
    ]
)
