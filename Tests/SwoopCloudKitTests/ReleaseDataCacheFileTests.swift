//
//  ReleaseDataCacheFileTests.swift
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

/// The disk cache's format-versioned envelope.
@Suite("Release data cache file")
internal struct ReleaseDataCacheFileTests {
  private let snapshot: ReleaseDataSnapshot

  internal init() throws {
    snapshot = try ReleaseDataSnapshot.fixture(ReleaseDataFixture.xcode27)
  }

  @Test(
    "The fixtures decode as snapshots",
    arguments: [ReleaseDataFixture.xcode27, ReleaseDataFixture.specExamples]
  )
  internal func fixturesDecode(name: String) throws {
    let fixture = try ReleaseDataFixture.load(name)
    let snapshot = try ReleaseDataSnapshot.fixture(name)
    #expect(snapshot.fetchedAt == fixture.fetchedAt)
    #expect(snapshot.sdkVersions == fixture.sdkVersions)
    #expect(snapshot.xcodeVersions.count == fixture.xcodeVersions.count)
  }

  @Test("A snapshot round-trips through the cache file")
  internal func roundTrip() throws {
    let data = ReleaseDataCacheFile.encode(snapshot)
    let decoded = try ReleaseDataCacheFile.decode(data)
    #expect(try decoded.jsonData() == snapshot.jsonData())
    #expect(decoded.fetchedAt == snapshot.fetchedAt)
    #expect(decoded.sdkVersions == snapshot.sdkVersions)
  }

  @Test("The file is the fixture shape plus the format version")
  internal func shape() throws {
    let data = ReleaseDataCacheFile.encode(snapshot)
    let object = try #require(
      try JSONSerialization.jsonObject(with: data) as? [String: Any]
    )
    let keys = Set(object.keys)
    #expect(
      keys == [
        "formatVersion", "fetchedAt", "sdkVersions", "xcodeVersions", "simulatorRuntimes",
      ]
    )
    #expect(object["formatVersion"] as? Int == ReleaseDataCacheFile.currentFormatVersion)
  }

  @Test("Another format version is rejected", arguments: [0, 2, 99])
  internal func otherVersion(version: Int) throws {
    let data = try snapshot.jsonData(formatVersion: version)
    #expect(throws: ReleaseDataCacheError.unsupportedFormatVersion(version)) {
      try ReleaseDataCacheFile.decode(data)
    }
  }

  @Test("A file with no format version is rejected")
  internal func noVersion() throws {
    let data = try snapshot.jsonData()
    #expect(throws: ReleaseDataCacheError.unsupportedFormatVersion(nil)) {
      try ReleaseDataCacheFile.decode(data)
    }
  }

  @Test("An old layout fails on its version, not its records")
  internal func oldLayout() throws {
    let data = Data(#"{"formatVersion": 0, "snapshot": {"records": []}}"#.utf8)
    #expect(throws: ReleaseDataCacheError.unsupportedFormatVersion(0)) {
      try ReleaseDataCacheFile.decode(data)
    }
  }

  @Test("Data that isn't a cache file throws", arguments: ["", "not json", "[]"])
  internal func corrupt(text: String) {
    #expect(throws: (any Error).self) {
      try ReleaseDataCacheFile.decode(Data(text.utf8))
    }
  }
}
