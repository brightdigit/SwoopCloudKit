//
//  SimulatorRuntimeRecord+CloudKit.swift
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

#if canImport(CloudKit)
  internal import CloudKit
  internal import Foundation
  internal import SwoopKit

  extension SimulatorRuntimeRecord {
    /// The field that holds the SDK builds as comma-separated text (MistKit#509).
    internal static let sdkBuildNumbersFieldName = "sdkBuildNumbersText"

    // swiftlint:disable todo
    /// Maps a public-database `SimulatorRuntime` record onto the shared model.
    ///
    /// The mirror of SwoopMistKit's `SimulatorRuntimeRecord.from(recordInfo:)`:
    /// `releaseLabel` is text ("Beta 4", "RC 1", "Final"), and the SDK builds are
    /// one comma-separated `STRING` in `sdkBuildNumbersText` that's absent when the
    /// index maps no SDK. `isPrerelease` is stored too, but the label already says it.
    ///
    /// The SDK builds aren't a `LIST<STRING>` because SwoopMistKit's writer, MistKit,
    /// can't decode that type in responses (brightdigit/MistKit#509).
    /// TODO: Read a `LIST<STRING>` again once SwoopMistKit switches back.
    ///
    /// - Parameter cloudKitRecord: The record returned by `CKQuery`.
    /// - Throws: ``CloudKitRecordMappingError`` when `platform`, `version`,
    ///   `buildNumber` or `releaseLabel` is missing, or the platform or label
    ///   is unknown.
    internal init(cloudKitRecord: CKRecord) throws(CloudKitRecordMappingError) {
      guard let platformValue = cloudKitRecord["platform"] as? String else {
        throw .missingField("platform")
      }
      guard let platform = Platform(rawValue: platformValue) else {
        throw .invalidPlatform(platformValue)
      }
      guard let version = cloudKitRecord["version"] as? String else {
        throw .missingField("version")
      }
      guard let buildNumber = cloudKitRecord["buildNumber"] as? String else {
        throw .missingField("buildNumber")
      }
      guard let labelValue = cloudKitRecord["releaseLabel"] as? String else {
        throw .missingField("releaseLabel")
      }
      guard let releaseLabel = ReleaseLabel(labelValue) else {
        throw .invalidReleaseLabel(labelValue)
      }
      self.init(
        platform: platform,
        version: version,
        buildNumber: buildNumber,
        releaseLabel: releaseLabel,
        sdkBuildNumbers: Self.sdkBuildNumbers(
          fromText: cloudKitRecord[Self.sdkBuildNumbersFieldName] as? String
        )
      )
    }
    // swiftlint:enable todo

    /// Splits `sdkBuildNumbersText`; a missing or empty value is `[]`.
    internal static func sdkBuildNumbers(fromText text: String?) -> [String] {
      guard let text else {
        return []
      }
      return text.split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty }
    }
  }
#endif
