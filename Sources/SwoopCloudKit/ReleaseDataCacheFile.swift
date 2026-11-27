//
//  ReleaseDataCacheFile.swift
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

public import Foundation
public import SwoopKit

/// A release-data disk cache's contents: a `ReleaseDataSnapshot` plus a
/// `formatVersion`, as JSON.
///
/// Bump ``currentFormatVersion`` when the snapshot or record layout
/// changes incompatibly. A cache from another format version then fails
/// to decode, the app ignores it, and the next fetch replaces it.
/// Adding `simulatorRuntimes` wasn't incompatible: a file without it
/// decodes with none.
///
/// This type only converts to and from `Data`. Reading and writing the
/// file, and where it lives, belong to the app.
public struct ReleaseDataCacheFile: Sendable, Codable {
  /// The format this build writes and reads.
  public static let currentFormatVersion = 1

  /// The format the file was written in.
  public let formatVersion: Int
  /// When the records were fetched from CloudKit.
  public let fetchedAt: Date
  /// The `SDKVersion` records.
  public let sdkVersions: [SDKVersionRecord]
  /// The `XcodeVersion` records.
  public let xcodeVersions: [XcodeVersionRecord]
  /// The `SimulatorRuntime` records.
  public let simulatorRuntimes: [SimulatorRuntimeRecord]

  /// The snapshot the file holds.
  public var snapshot: ReleaseDataSnapshot {
    ReleaseDataSnapshot(
      fetchedAt: fetchedAt,
      sdkVersions: sdkVersions,
      xcodeVersions: xcodeVersions,
      simulatorRuntimes: simulatorRuntimes
    )
  }

  /// A file in the current format.
  ///
  /// - Parameter snapshot: The snapshot to hold.
  public init(_ snapshot: ReleaseDataSnapshot) {
    formatVersion = Self.currentFormatVersion
    fetchedAt = snapshot.fetchedAt
    sdkVersions = snapshot.sdkVersions
    xcodeVersions = snapshot.xcodeVersions
    simulatorRuntimes = snapshot.simulatorRuntimes
  }

  /// Decodes a file; a missing `simulatorRuntimes` is empty.
  ///
  /// - Parameter decoder: The decoder to read from.
  /// - Throws: A `DecodingError` when a required key is missing or a record
  ///   doesn't decode.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    formatVersion = try container.decode(Int.self, forKey: .formatVersion)
    fetchedAt = try container.decode(Date.self, forKey: .fetchedAt)
    sdkVersions = try container.decode([SDKVersionRecord].self, forKey: .sdkVersions)
    xcodeVersions = try container.decode(
      [XcodeVersionRecord].self,
      forKey: .xcodeVersions
    )
    simulatorRuntimes =
      try container.decodeIfPresent(
        [SimulatorRuntimeRecord].self,
        forKey: .simulatorRuntimes
      ) ?? []
  }

  /// The JSON for `snapshot` in the current format.
  ///
  /// The JSON is pretty-printed with sorted keys and ISO 8601 dates
  /// (SwoopKit's `JSONEncoder.iso8601PrettySorted`), so it's stable and
  /// diffable.
  ///
  /// - Parameter snapshot: The snapshot to encode.
  /// - Returns: The cache file's contents.
  public static func encode(_ snapshot: ReleaseDataSnapshot) -> Data {
    JSONEncoder.iso8601PrettySorted.encodeAsserting(Self(snapshot))
  }

  /// The snapshot in a cache file's JSON.
  ///
  /// - Parameter data: A cache file's contents.
  /// - Returns: The snapshot the file holds.
  /// - Throws: ``ReleaseDataCacheError/unsupportedFormatVersion(_:)`` for
  ///   a file in another format (checked before the records are decoded),
  ///   or ``ReleaseDataCacheError/unreadable(_:)`` for a file that isn't a
  ///   cache file.
  public static func decode(
    _ data: Data
  ) throws(ReleaseDataCacheError) -> ReleaseDataSnapshot {
    let decoder = JSONDecoder.iso8601
    let header: Header
    do {
      header = try decoder.decodeValue(Header.self, from: data)
    } catch {
      throw .unreadable(error)
    }
    guard header.formatVersion == currentFormatVersion else {
      throw .unsupportedFormatVersion(header.formatVersion)
    }
    do {
      return try decoder.decodeValue(Self.self, from: data).snapshot
    } catch {
      throw .unreadable(error)
    }
  }
}

extension ReleaseDataCacheFile {
  /// Just the version, so an old layout isn't decoded as records.
  private struct Header: Decodable {
    let formatVersion: Int?
  }
}
