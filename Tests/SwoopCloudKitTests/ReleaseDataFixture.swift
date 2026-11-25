//
//  ReleaseDataFixture.swift
//  SwoopCloudKit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

internal import Foundation
internal import SwoopKit
internal import Testing

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
        subdirectory: "release-data"
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
