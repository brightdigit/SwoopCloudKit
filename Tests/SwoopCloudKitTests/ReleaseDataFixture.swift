//
// ReleaseDataFixture.swift
// Copyright (c) 2026 BrightDigit.
//

internal import Foundation
internal import Testing

internal import SwoopKit

/// Reads the release-data fixtures in `Resources/release-data/`.
///
/// `xcode-27`, `spec-examples` and `simulator-runtimes-27` are copies of
/// Stewed's `docs/fixtures/release-data/` (see its README for how each was
/// made). `cache-format-1` is a cache file written by Stewed's
/// `ReleaseDataCacheFile` before it moved here: `xcode-27`'s records plus
/// `simulator-runtimes-27`'s.
///
/// Decoding here uses a plain `JSONDecoder`, not SwoopCloudKit's types, so
/// tests can compare the two.
internal struct ReleaseDataFixture: Decodable {
  /// Records derived from the real Xcode 27.0–27.2 releases.
  internal static let xcode27 = "xcode-27"
  /// Illustrative records with invented builds.
  internal static let specExamples = "spec-examples"
  /// Runtime records parsed from Apple's simulator index on 2026-11-17.
  internal static let simulatorRuntimes27 = "simulator-runtimes-27"
  /// A format version 1 cache file written before the move.
  internal static let cacheFormat1 = "cache-format-1"

  internal let fetchedAt: Date
  internal let sdkVersions: [SDKVersionRecord]
  internal let xcodeVersions: [XcodeVersionRecord]

  /// The raw contents of `<name>.json`.
  internal static func data(_ name: String) throws -> Data {
    let url = try #require(
      Bundle.module.url(
        forResource: name,
        withExtension: "json",
        subdirectory: "Resources/release-data"
      )
    )
    return try Data(contentsOf: url)
  }

  /// Loads `<name>.json`.
  internal static func load(_ name: String) throws -> Self {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(Self.self, from: data(name))
  }
}
