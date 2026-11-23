// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "SwoopCloudKit",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(name: "SwoopCloudKit", targets: ["SwoopCloudKit"])
  ],
  dependencies: [
    // `simulator` branch overlay: build against the sibling SwoopKit subrepo.
    // Upstream `main` uses the SwoopKit URL instead.
    .package(name: "SwoopKit", path: "../SwoopKit")
  ],
  targets: [
    .target(
      name: "SwoopCloudKit",
      dependencies: [
        .product(name: "SwoopKit", package: "SwoopKit")
      ],
      swiftSettings: [
        .enableUpcomingFeature("InternalImportsByDefault")
      ]
    ),
    .testTarget(
      name: "SwoopCloudKitTests",
      dependencies: [
        "SwoopCloudKit",
        .product(name: "SwoopKit", package: "SwoopKit"),
      ],
      resources: [
        // Release-data fixtures: snapshots and a cache file written before
        // the snapshot moved here from Stewed.
        .copy("Resources")
      ],
      swiftSettings: [
        .enableUpcomingFeature("InternalImportsByDefault")
      ]
    ),
  ]
)
