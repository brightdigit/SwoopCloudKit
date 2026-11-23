//
// ReleaseDataCompatibilityTests.swift
// Copyright (c) 2026 BrightDigit.
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
