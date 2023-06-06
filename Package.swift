// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "brainpac-nih-ios",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "brainpac-nih-ios",
            targets: ["UnityFramework"]),
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
            url: "https://github.com/BrainPark/brainpac-nih-ios/releases/download/v1.0.2-alpha/UnityFramework.xcframework.zip",
            checksum: "94ef1a1f28eaecd48f82001f0bcdc7ecabd16638c0b48a173a804f1bd30f0808"
        ),
    ]
)
