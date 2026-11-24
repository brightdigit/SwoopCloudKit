//
//  ReleaseDataSnapshot+Testing.swift
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
