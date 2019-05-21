// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Tuxedo",
    products: [
        .library(
            name: "Tuxedo",
            targets: ["Tuxedo"])
    ],
    dependencies: [
        .package(url: "https://github.com/tevelee/Eval", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "Tuxedo",
            dependencies: ["Eval"]),
        .testTarget(
            name: "TuxedoTests",
            dependencies: ["Tuxedo"])
    ]
)
