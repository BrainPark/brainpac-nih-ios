// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "brainpac-nih-ios",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "brainpac-nih-ios",
            targets: ["BrainPAC"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "UnityFramework",
            url: "https://github.com/BrainPark/brainpac-nih-ios/releases/latest/download/UnityFramework.xcframework.zip",
            checksum: "acb5826d729858e1872a185dc34955c74d81743f5ee7b306564f035846e8c956"
        ),
        
        .target(
            name: "BrainPAC",
            dependencies: [
                .target(name: "UnityFramework"),
            ]
        ),

    ]
)
