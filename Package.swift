// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "BushelCatalog",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(name: "BushelCatalog", targets: ["BushelCatalog"])
  ],
  dependencies: [
    // `simulator` branch overlay: build against the sibling BushelKit subrepo.
    // Upstream `main` uses the BushelKit URL instead.
    .package(name: "BushelKit", path: "../BushelKit")
  ],
  targets: [
    .target(
      name: "BushelCatalog",
      dependencies: [
        .product(name: "BushelFoundation", package: "BushelKit")
      ],
      swiftSettings: [
        .enableUpcomingFeature("InternalImportsByDefault")
      ]
    )
  ]
)
