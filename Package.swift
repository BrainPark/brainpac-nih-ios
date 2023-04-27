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
            url: "https://api.github.com/repos/BrainPark/brainpac-nih-ios/releases/assets/105518582.zip",
            checksum: "a08d82d677796569ade2d9ab5d9d319e170215ca34c1af4611dd000dd7a93c65"
        ),
    ]
)
