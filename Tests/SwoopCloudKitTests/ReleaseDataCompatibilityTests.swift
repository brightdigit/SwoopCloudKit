//
//  ReleaseDataCompatibilityTests.swift
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
internal import Testing

@testable internal import SwoopCloudKit

/// Files written before the snapshot and cache file moved here from Stewed
/// still decode, and the JSON written now is byte for byte the same.
@Suite("Release data compatibility")
internal struct ReleaseDataCompatibilityTests {
  @Test("A cache written before the move decodes")
  internal func oldCacheDecodes() throws {
    let data = try ReleaseDataFixture.data(ReleaseDataFixture.cacheFormat1)
    let decoded = try ReleaseDataCacheFile.decode(data)
    let xcode = try ReleaseDataSnapshot.fixture(ReleaseDataFixture.xcode27)
    let runtimes = try ReleaseDataSnapshot.fixture(ReleaseDataFixture.simulatorRuntimes27)
    #expect(decoded.fetchedAt == xcode.fetchedAt)
    #expect(decoded.sdkVersions == xcode.sdkVersions)
    #expect(decoded.xcodeVersions.count == xcode.xcodeVersions.count)
    #expect(decoded.simulatorRuntimes == runtimes.simulatorRuntimes)
  }

  @Test("Re-encoding a cache written before the move gives the same bytes")
  internal func oldCacheRoundTripsByteForByte() throws {
    let data = try ReleaseDataFixture.data(ReleaseDataFixture.cacheFormat1)
    let decoded = try ReleaseDataCacheFile.decode(data)
    #expect(ReleaseDataCacheFile.encode(decoded) == data)
  }

  @Test("A cache from before simulator runtimes decodes with none")
  internal func cacheWithoutRuntimes() throws {
    let snapshot = try ReleaseDataSnapshot.fixture(ReleaseDataFixture.xcode27)
    let data = try snapshot.jsonData(formatVersion: 1)
    let object = try #require(
      try JSONSerialization.jsonObject(with: data) as? [String: Any]
    )
    let trimmed = try JSONSerialization.data(
      withJSONObject: object.filter { $0.key != "simulatorRuntimes" }
    )
    let decoded = try ReleaseDataCacheFile.decode(trimmed)
    #expect(decoded.simulatorRuntimes.isEmpty)
    #expect(decoded.sdkVersions == snapshot.sdkVersions)
  }

  @Test("The runtime records round-trip through the cache file")
  internal func runtimesRoundTrip() throws {
    let snapshot = try ReleaseDataSnapshot.fixture(ReleaseDataFixture.simulatorRuntimes27)
    #expect(!snapshot.simulatorRuntimes.isEmpty)
    let decoded = try ReleaseDataCacheFile.decode(ReleaseDataCacheFile.encode(snapshot))
    #expect(decoded.simulatorRuntimes == snapshot.simulatorRuntimes)
  }

  @Test("A snapshot without runtimes decodes with none")
  internal func snapshotWithoutRuntimes() throws {
    let snapshot = try ReleaseDataSnapshot.fixture(ReleaseDataFixture.xcode27)
    #expect(snapshot.simulatorRuntimes.isEmpty)
    #expect(!snapshot.sdkVersions.isEmpty)
  }
}
