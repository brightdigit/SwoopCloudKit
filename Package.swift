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
  // The Apple minimums match SwoopKit's, except macOS 14, which this
  // package's consumers need.
  platforms: [
    .macOS(.v14),
    .iOS(.v18),
    .watchOS(.v11),
    .tvOS(.v18),
    .visionOS(.v2),
    .macCatalyst(.v18),
  ],
  products: [
    .library(name: "SwoopCloudKit", targets: ["SwoopCloudKit"])
  ],
  dependencies: [
    .package(url: "https://github.com/brightdigit/SwoopKit.git", from: "1.0.0-beta.1")
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
        .copy("Resources/release-data")
      ],
      swiftSettings: [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
