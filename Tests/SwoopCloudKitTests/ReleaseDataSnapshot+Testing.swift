//
// ReleaseDataSnapshot+Testing.swift
// Copyright (c) 2026 BrightDigit.
//

internal import Foundation

@testable internal import SwoopCloudKit

extension ReleaseDataSnapshot {
  /// The fixture `<name>.json` as a snapshot.
  internal static func fixture(_ name: String) throws -> Self {
    try Self(json: ReleaseDataFixture.data(name))
  }

  /// Canonical JSON, for comparing snapshots.
  ///
  /// `XcodeVersionRecord` isn't `Equatable`. With `formatVersion`, the
  /// JSON is a hand-made cache file.
  internal func jsonData(formatVersion: Int? = nil) throws -> Data {
    let data = try JSONEncoder.iso8601PrettySorted.encode(self)
    guard let formatVersion else {
      return data
    }
    let json = try JSONSerialization.jsonObject(with: data)
    guard var object = json as? [String: Any] else {
      throw CocoaError(.coderReadCorrupt)
    }
    object["formatVersion"] = formatVersion
    return try JSONSerialization.data(withJSONObject: object)
  }
}
