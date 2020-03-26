// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MeatNetworking",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [

        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "MeatNetworking",
            targets: ["MeatNetworking"])
    ],
    dependencies: [

        // Dependencies declare other packages that this package depends on.
        .package(url: "ssh://tfs.ia.corp.svea.com:22/SveaBankCollection/Payd%20-%20The%20rest%20is%20easy/_git/ios-meat-futures", from: Version(0, 1, 0))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "MeatNetworking",
            dependencies: ["MeatFutures"]),
        .testTarget(
            name: "MeatNetworkingTests",
            dependencies: ["MeatNetworking"])
    ]
)
