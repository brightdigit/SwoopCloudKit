// swift-tools-version: 6.4

import PackageDescription

// A read-only reader for the public CloudKit database SwoopMistKit writes,
// using native CloudKit. The CloudKit types build only where CloudKit exists;
// the release-data snapshot and cache file build everywhere SwoopKit does.
//
// DocC: Scripts/docc.sh builds the catalog without swift-docc-plugin, so
// packages that depend on SwoopCloudKit never resolve the plugin.
let package = Package(
  name: "SwoopCloudKit",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(name: "SwoopCloudKit", targets: ["SwoopCloudKit"])
  ],
  dependencies: [
    // `simulator` branch overlay: build against SwoopKit's `simulator` branch.
    // Upstream `main` uses the SwoopKit URL instead.
    .package(url: "https://github.com/brightdigit/SwoopKit.git", branch: "simulator")
  ],
  targets: [
    .target(
      name: "SwoopCloudKit",
      dependencies: [
        .product(name: "SwoopKit", package: "SwoopKit")
      ],
      swiftSettings: [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
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
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
